import { context, build } from "esbuild";
import { solidPlugin } from "esbuild-plugin-solid";

const args = process.argv.slice(2);
const watch = args.includes("--watch");
const deploy = args.includes("--deploy");

const loader = { ".js": "jsx", ".svg": "file" };

const plugins = [solidPlugin()];

// Define esbuild options
let opts = {
  entryPoints: ["js/app.js", "js/solidAppHook.js"],
  bundle: true,
  logLevel: "info",
  target: "es2021",
  outdir: "../priv/static/assets",
  external: ["*.css", "fonts/*", "images/*"],
  loader: loader,
  plugins: plugins,
  format: "esm",
};

if (deploy) {
  opts = {
    ...opts,
    minify: true,
    splitting: true,
  };
  build(opts);
}

if (watch) {
  opts = {
    ...opts,
    sourcemap: "inline",
  };

  context(opts)
    .then((ctx) => (watch ? ctx.watch() : build(opts)))
    .catch((error) => {
      console.log(`Build error: ${error}`);
      process.exit(1);
    });
}
