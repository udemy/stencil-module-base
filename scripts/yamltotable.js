const fs = require('fs');
const yaml = require('js-yaml');
const { execSync } = require('child_process');

const file = fs.readFileSync('manifest.yaml', 'utf8');
const data = yaml.load(file);

if (!data.arguments) {
    console.log("No arguments found, skipping...");
    process.exit(0);
}

const headLines = [
    "## Manifest Arguments",
    "",
    "In the `arguments` section of your project's `stencil.yaml` file, you can specify the following options:",
    "",
];

function splitName(name) {
    const mp = name.split('/');
    if (mp.length !== 3) {
        throw new Error(`Invalid name: ${name}`);
    }
    if (mp[0] != "github.com") {
        throw new Error(`Invalid name: ${name}`);
    }
    // Check for characters outside of a-zA-Z0-9-_.
    const allowedChars = /^[a-zA-Z0-9-_.]+$/;
    for (let i = 1; i <= 2; i++) {
        if (!allowedChars.test(mp[i])) {
            throw new Error(`Invalid character in ${name}: ${mp[i]}`);
        }
    }
    return [mp[1], mp[2]];
}

let modules = { [data.name]: data };
if (data.modules) {
    let toFetch = data.modules.map(m => m.name);
    while (toFetch.length > 0) {
        const m = toFetch.shift();
        if (m in modules) {
            continue;
        }

        console.log(`Fetching ${m} manifest...`);
        const mp = splitName(m);
        try {
            const result = execSync(`gh api repos/${mp[0]}/${mp[1]}/contents/manifest.yaml --header "Accept: application/vnd.github.v3.raw"`);
            const manifest = yaml.load(result.toString());
            modules[m] = manifest;
            if (manifest.modules) {
                toFetch.push(...manifest.modules.map(m => m.name));
            }
        } catch (e) {
            throw new Error(`Error fetching ${m}: ${e.message}`);
        }
    }
}

function getArgInfo(m, k) {
    if (!modules[m]) {
        throw new Error(`Module ${m} not found`);
    }
    if (!modules[m].arguments) {
        throw new Error(`No arguments found for ${m}`);
    }
    const v = modules[m].arguments[k];
    if (!v) {
        throw new Error(`Argument ${k} not found for ${m}`);
    }
    if (v.from) {
        return getArgInfo(v.from, k);
    }
    return v;
}

let out = `| Option | Default | Description |
| ------ | ------- | ----------- |
`;

for (const [k, v] of Object.entries(data.arguments)) {
    let fromHead = "";
    if (v.from) {
        const vp = splitName(v.from);
        fromHead = `(From [${vp[0]}/${vp[1]}](https://github.com/${vp[0]}/${vp[1]})) `;
    }

    let ai = getArgInfo(data.name, k);
    let def = "";
    if (typeof ai.default !== 'undefined') {
        if (typeof ai.default === 'string') {
            def = `"${ai.default}"`;
        } else {
            def = ai.default.toString();
        }
    } else if (ai.required) {
        def = '[required]';
    } else if (!ai.required) {
        if (ai.schema && ai.schema.type === 'boolean') {
            def = 'false';
        } else if (ai.schema && ai.schema.type === 'string') {
            def = '""';
        } else {
            def = '[none]';
        }
    }
    let desc = (ai.description || "").trim();
    const hasDef = desc.indexOf("(default: ");
    if (hasDef !== -1) {
        desc = desc.substring(0, hasDef).trim();
    }
    desc = desc.replace(/\n/g, '<br>');
    out += `| ${k} | ${def} | ${fromHead}${desc} |\n`;
}

let readme = "";
try {
    readme = fs.readFileSync("README.md", "utf8");
} catch (e) {
    console.log("No README.md found, creating one...");
    readme = "";
}
const lines = readme.split('\n');
let firstLine = lines.indexOf("## Manifest Arguments");
let lastLine = -1;
if (firstLine !== -1) {
    let inTable = false;
    let otherSection = -1;
    for (let i = firstLine + 1; i < lines.length; i++) {
        if (otherSection === -1 && lines[i - 1] === "" && lines[i].startsWith("#")) {
            otherSection = i;
        }
        const isTable = lines[i].startsWith("|");
        if (inTable) {
            if (!isTable) {
                lastLine = i;
                break;
            }
        } else if (isTable) {
            inTable = true;
        }
    }
    if (lastLine === -1) {
        // Use last section if exists
        if (otherSection !== -1) {
            lastLine = Math.max(firstLine, otherSection - 2);
        } else {
            // Use end of file
            lastLine = lines.length - 1;
        }
    }
}

// Reassemble
const outLines = out.split("\n");

let newReadme = "";
if (firstLine !== -1 && lastLine !== -1) {
    newReadme = [...lines.slice(0, firstLine), ...headLines, ...outLines, ...lines.slice(lastLine + 1)].join('\n');
} else {
    newReadme = [...lines, "", ...headLines, ...outLines, ""].join('\n');
}
fs.writeFileSync("README.md", newReadme);

console.log("Updated README.md!");
