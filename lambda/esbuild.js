const esbuild = require('esbuild');

esbuild
    .build({
        entryPoints:[
            'src/functions/test-function.ts'
        ],
        outdir: 'build',
        bundle: true,
        minify: true,
        sourcemap: true,
        target: 'node14',
        splitting: false,
        format: 'cjs',
        platform: 'node'
    })
    .catch(() => process.exit(1));