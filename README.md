# ghūl core library

The base class library for ghūl programs on the WebAssembly target, as
ghūl source. On .NET a program's strings, collections, exceptions and
console come from the .NET base class library; on WasmGC none of that
exists, so it is supplied here and compiled into the program.

Nothing is declared under `System`: the library's types carry the ghūl
names settled in [ghul-lang/ghul#3230](https://github.com/ghul-lang/ghul/issues/3230),
which are the names a .NET program uses too, so one program compiles for
both targets unchanged. The built-in types themselves — the scalars,
`object`, `string`, the array, function and tuple shapes — are
constructed by the compiler under `--target wasm`; this library reopens
them with `partial` blocks to give them their members, and declares
everything else outright.

This is the hello-world tier: declarations whose bodies throw
`Ghul.NotImplementedException`, enough for a program that writes lines,
iterates an array and throws an exception to pass every front-end pass
under `--target wasm`. Real bodies arrive tier by tier, as the backend
gives tests something to run ([ghul-lang/ghul#3224](https://github.com/ghul-lang/ghul/issues/3224)).

## Layout

- `src/` — one file per type
- `tests/hello.ghul` — the program the library exists to compile
- `tests/type-error.ghul` — a program whose one type error must report
  against the library's declarations
- `tests/run.sh` — compiles both under `--target wasm` and checks the
  diagnostics

## Testing

```sh
dotnet tool restore
tests/run.sh
```

The hello program passes when the only diagnostic is the code-generation
error (the WasmGC backend does not exist yet); the type-error program
passes when the error names the member and its place. Compiling the
library needs ghul.compiler 64.10.0 or later.
