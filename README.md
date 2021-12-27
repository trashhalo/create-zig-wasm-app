# Create Zig Wasm App

Boilerplate to stand up a SPA app using Zig 0.9 for webassembly and Vite. Commands sent using [WAPC](https://wapc.io/).

## Getting started

- Get npm/node
- Get zig 0.9
- Get gyro for package management
- Create a deps.zig by running "gyro fetch"
- Build wasm payload
- `npm install` to setup vite dependencies
- `npm run dev` to start your dev server
- Point your browser at localhost:3000

## Source material
- [zig-wasm-dom](https://github.com/shritesh/zig-wasm-dom) inspiration on how one might pass js objects back and forth
- [tetris](https://github.com/raulgrell/tetris) much bigger example
- [go's syscall](https://pkg.go.dev/syscall/js) example implementation of an api to give a wasm guest control over a js host env.
