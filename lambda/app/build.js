import * as esbuild from "esbuild";

await esbuild.build({
  bundle: true,
  entryPoints: ["./src/index.ts"],
  outdir: "dist",
  outExtension: {
    ".js": ".mjs",
  },
  platform: "node",
  target: "esnext",
  format: "esm",
});
