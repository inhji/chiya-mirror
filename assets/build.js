const esbuild = require('esbuild')

const args = process.argv.slice(2)
const watch = args.includes('--watch')
const deploy = args.includes('--deploy')

const loader = {
  // Add loaders for images/fonts/etc, e.g. { '.svg': 'file' }
  '.js': 'jsx'
}

const plugins = [
  // Add and configure plugins here
]

let opts = {
  entryPoints: [
    'js/app.js', 
    'js/public.js'
  ],
  bundle: true,
  target: 'es2016',
  outdir: '../priv/static/assets',
  external: ["*.css", "fonts/*", "images/*"],
  logLevel: 'info',
  loader,
  plugins
}

if (watch) {
  opts = {
    ...opts,
    sourcemap: 'inline'
  }
}

if (deploy) {
  opts = {
    ...opts,
    minify: true
  }
}

const promise = esbuild.build(opts)

if (watch) {
  esbuild.context(opts).then(ctx => ctx.watch())
}