#!/bin/bash

# Create web build directory
mkdir -p dist

# Copy static files
cp src/index.html dist/
cp src/styles.css dist/

# Build Swift code for web
swift build -c release --triple wasm32-unknown-wasi

# Copy WASM bundle
cp .build/release/will_it_rain_on_thursday.wasm dist/

# Create web bundle
cat > dist/main.js << EOF
import { WASI } from '@wasmer/wasi'
import { WasmFs } from '@wasmer/wasmfs'

export async function main() {
    const wasmFs = new WasmFs()
    const wasi = new WASI({
        args: [],
        env: {},
        bindings: {
            ...WASI.defaultBindings,
            fs: wasmFs
        }
    })

    const response = await fetch('will_it_rain_on_thursday.wasm')
    const buffer = await response.arrayBuffer()
    const module = await WebAssembly.compile(buffer)
    const instance = await WebAssembly.instantiate(module, {
        wasi_snapshot_preview1: wasi.wasiImport
    })

    wasi.start(instance)
}
EOF 