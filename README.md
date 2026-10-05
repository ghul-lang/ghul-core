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

- `ghul-project.json` — the library manifest (#3212 shape): name, targets,
  sources. Nothing reads it yet; the `ghul` tool that will (#3211)
  consumes the library from Git as source (#3179)
- `src/` — one file per type, plus `intrinsics.ghul`, the operators on the
  built-in types, kept in step with ghul-runtime's
  and `comparison.ghul`, the scalar types' `Equatable` and `Comparable`
- `tests/hello` — the program the library exists to compile
- `tests/type-error` — a program whose one type error must report
  against the library's declarations
- `tests/operators` — a program using the scalar operators
- `tests/comparison` — `=~` and the relational operators over each scalar
  type
- `tests/decimal` — `=~`, ordering and arithmetic on `decimal`
- `tests/ranges` — the `..` and `::` operators and the range types they
  produce
- `tests/maybe` — `MAYBE` and `KEY_VALUE_PAIR`
- `tests/math` — `Math`'s constants and functions, against .NET's values
- `tests/random` — `RANDOM`: a seed fixes the sequence, and every value is in range
- `tests/list` — `LIST` and the list traits
- `tests/map` — `MAP`, `SET` and the map and set traits, and finding
  elements of a `LIST` by `=~`
- `tests/stack-queue` — `STACK`, `Queue`, the set operations on `SET`,
  and a `KEY_VALUE_PAIR` destructured by position
- `tests/float_text` — `to_string` on `double` and `single`
- `tests/float_text_dotnet` — the floating-point formatter compiled for .NET
  and checked against .NET's own text for boundary values and random bit
  patterns
- `tests/number_format` — the numeric types' `to_string(format)` on the wasm target,
  against the text .NET writes for the same calls
- `tests/number_format_dotnet` — the numeric formatter compiled for .NET and
  checked against .NET's own text for fixed and random values of every
  magnitude, under every format the formatter covers
- `tests/list_sort` — `LIST.sort` with a comparer and with a comparison function
- `tests/sort_dotnet` — the sort compiled for .NET and checked against
  .NET's `List.Sort` for where it leaves elements the comparer calls equal
- `tests/bigint` — bigint's operators and members, each a host operation on the
  host's BigInt, against the text .NET prints for the same program
- `tests/bigint_conversions` — `cast` between bigint and the scalars, bigint under
  numeric formats and reached as `object`, and division by zero, against
  .NET's text
- `tests/string_members` — the string members: search, trim, split, replace,
  padding, casing and comparison
- `tests/string_hash` — strings that are `=~` hash alike, and a union with a
  string field compared by its contents
- `tests/std_writers` — standard output and standard error written through
  `IO.Std` and through its `out` and `error` writers
- `tests/tuples` — tuple elements read by position and by name, and a
  tuple destructured
- `tests/exceptions` — the exceptions the compiler makes or catches on the
  wasm target, each with the constructor it uses
- `tests/display` — `$`, `inspect` and interpolation over records, union
  variants, tuples, sequences and a `Displayable`, as .NET writes them
- `tests/environment` — a program reading, writing and removing variables
  through its `Ghul.Environment`
- `tests/arguments` — a program reading the command-line arguments it was
  run with

Each test directory is a ghul-cli project whose `ghul-project.json` takes
ghul-core from this checkout (`"path": "../.."`), so the program compiles
against the library's own sources as a user's wasm build would, with the
pinned ghul-runtime after it. Beside it are expectation files for what the
compiler should say and what the program prints. A test that builds runs
under Node; `tests/float_text_dotnet` builds for .NET. Where the wasm
target cannot yet compile what a test exercises, its expectation is the
diagnostic that says so, and a comment in the test names what it waits for.

## Testing

```sh
dotnet tool restore
dotnet ghul-test --use-ghul-cli --ghul "dotnet ghul" tests
```

Each project builds with the newest installed `ghul.compiler`, which ghul-cli
installs if there is none. The type-error test passes when the error names
the member and its place.
