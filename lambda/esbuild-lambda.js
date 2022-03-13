const esbuild = require('esbuild');
const fs = require('fs');

let buildConfig = JSON.parse(fs.readFileSync('./build-config.json'));

let esbuildOptions = {
    bundle: true,
    minify: true,
    sourcemap: true,
    target: 'node14',
    splitting: false,
    format: 'cjs',
    platform: 'node'
};

for (let lambdaConfig of buildConfig.lambdas) {
    esbuildOptions.entryPoints = [lambdaConfig.esbuildEntrypoint];
    esbuildOptions.outdir = `build/${lambdaConfig.name}`;

    console.log(`Building with options: ${JSON.stringify(esbuildOptions)}`);
    esbuild.build(esbuildOptions).catch(() => process.exit(1));

    for (let addnlFile of lambdaConfig.additionalFiles) {
        let filePath = addnlFile.substring(0, addnlFile.lastIndexOf('/'));
        filePath = `./${esbuildOptions.outdir}/${filePath}`;
        if (!fs.existsSync(filePath)) {
            fs.mkdirSync(filePath, {
                recursive: true
            });
        }
        fs.copyFileSync(`./${addnlFile}`, `${esbuildOptions.outdir}/${addnlFile}`);
    }

    esbuildOptions.entryPoints = undefined;
    esbuildOptions.outdir = undefined;
}
