# Clairvoyant

A CLI that visualizes a project's dependency tree straight from its lockfile.

## Supported lockfiles

- `mix.lock` (Elixir/Hex)
- `Cargo.lock` (Rust/Cargo)
- `poetry.lock` (Python/Poetry)
- `uv.lock` (Python/uv)

## Build

```
mix escript.build
```

This produces a `clairvoyant` executable in the project root.

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
