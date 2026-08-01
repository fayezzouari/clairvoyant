# Clairvoyant

A CLI that visualizes a project's dependency tree straight from its lockfile.

## Supported lockfiles

- `mix.lock` (Elixir/Hex)
- `Cargo.lock` (Rust/Cargo)
- `poetry.lock` (Python/Poetry)
- `uv.lock` (Python/uv)

## Install

Download a prebuilt standalone binary (no Erlang/Elixir required) from the
[latest release](https://github.com/fayezzouari/clairvoyant/releases/latest)
for macOS (Intel/Apple Silicon), Linux, or Windows.

## Build from source

```
mix escript.build
```

This produces a `clairvoyant` executable in the project root. Requires
Erlang/Elixir to be installed on the machine running it.

## Usage

```
clairvoyant <lockfile> [options]
```

Options:

- `--depth N` — limit tree depth
- `--only PACKAGE` — show only the subtree rooted at PACKAGE
- `--reverse PACKAGE` — show what depends on PACKAGE (walks ancestors)
- `--help`, `-h` — show usage

Examples:

```
clairvoyant mix.lock
clairvoyant Cargo.lock --depth 2
clairvoyant poetry.lock --only requests
clairvoyant mix.lock --reverse jason
```

## Development

```
mix deps.get
mix test
```

## Releasing standalone binaries

Pushing a tag matching `v*.*.*` triggers `.github/workflows/release.yml`,
which uses [Burrito](https://github.com/burrito-elixir/burrito) to build
self-contained binaries (bundled Erlang runtime, no local install needed)
for macOS (Intel + Apple Silicon), Linux, and Windows, and attaches them to
a GitHub Release:

```
git tag v0.1.0
git push origin v0.1.0
```

To build these locally, you need `zig` (0.15.x), `xz`, and `7z` on your
`PATH`, then run `MIX_ENV=prod mix release`. Binaries land in
`burrito_out/`.
