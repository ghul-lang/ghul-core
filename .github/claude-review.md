# Cloud code review brief

What this repository is, and what to watch for in it. Everything else — what PR
context is available, how to post a review, what makes a finding worth raising,
comment hygiene, PR-description shape, the versioning mechanism — comes from the
review workflow's runtime notes. Don't restate it here: this file is read first,
so a stale copy would silently override the current text.

## What this repo is

The ghūl core library: the base class library for ghūl programs on the
WebAssembly target, written in ghūl. Under `--target wasm` the compiler
constructs the built-in types itself (the scalars, `object`, `string`, the
array, function and tuple shapes); this library reopens them with `partial`
blocks to give them members, and declares everything else a program needs
outright. It is compiled into the program as source rather than referenced as
an assembly.

Its types carry the names a .NET program uses, so that one ghūl program
compiles for both targets unchanged. `GHUL.md`, fetched into the workspace, is
the authority on the language; where the library and `GHUL.md` disagree about
what a program can write, that is a finding.

## What to watch for here

- **Source compatibility with .NET.** A public type or member whose name,
  signature or behaviour differs from what the same ghūl program sees on .NET
  makes a program compile on one target and not the other. Nothing is declared
  under `System`.
  While the wasm backend is under construction, a difference from the .NET
  surface is acceptable when the pull request's description names the
  ghul-lang/ghul issue that tracks closing it. A difference the description
  does not name is still a finding.
- **`Ghul.Internal` stays unnameable from source.** It holds facts the compiler
  establishes, not something a program chooses; a declaration that makes one
  of its members reachable by name from a program is a finding.
- **Stub bodies.** A body that throws `Ghul.NotImplementedException` is the
  expected shape until the backend can run it. A body that returns a plausible
  but wrong value instead is worse than the stub, because a test can pass on it.
- **Tests.** Each directory under `tests/` compiles a program together with the
  library under `--target wasm` and checks what the compiler says. A change to
  the library's public surface wants a test that would notice it going.
- **Doc comments on the stable surface.** For the shared doc-comment rule, the
  stable surface here is the library's public types and members.

## Versioning

The consumer-visible contract is the library's public surface: the types and
members a program can name, and their signatures. Major means breaking it: a
removed or renamed public type or member, or a signature a program written
against the previous version no longer compiles against. Minor means
additions: new public types or members. A real body replacing a stub, or a
fix that leaves signatures alone, is a patch.

While `VERSION` is below 1.0.0, a breaking change is a minor bump, as semver
treats a 0.x release; moving to 1.0.0 is the maintainer's decision and is not
requested in review.
