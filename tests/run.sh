#!/bin/sh
# Compiles the library's files with each test program under --target
# wasm and checks the diagnostics. The hello program passes when the
# only diagnostic is the code-generation error; the type-error program
# passes when its one type error is reported at the member that lacks it.
set -u

cd "$(dirname "$0")/.."

sources=$(ls src/*.ghul)

status=0

expect_hello() {
    output=$(dotnet ghul-compiler --target wasm $sources tests/hello.ghul 2>&1)
    expected=0

    echo "$output" | grep -q "code generation for the wasm target is not supported" || expected=1

    others=$(echo "$output" | grep -E ': (error|warn):' | grep -v "code generation for the wasm target")
    if [ -n "$others" ]; then
        echo "hello: unexpected diagnostics:"
        echo "$others"
        expected=1
    fi

    if [ "$expected" = 0 ]; then
        echo "hello: ok"
    else
        status=1
    fi
}

expect_type_error() {
    output=$(dotnet ghul-compiler --target wasm $sources tests/type-error.ghul 2>&1)

    if echo "$output" | grep -q "member missing_thing not found in string"; then
        echo "type-error: ok"
    else
        echo "type-error: the type error was not reported against the library:"
        echo "$output" | grep -E ': (error|warn):' | head -3
        status=1
    fi
}

expect_hello
expect_type_error

exit $status
