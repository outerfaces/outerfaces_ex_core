# Outerfaces Elixir Core

[![Hex.pm](https://img.shields.io/hexpm/v/outerfaces.svg)](https://hex.pm/packages/outerfaces)
[![HexDocs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/outerfaces)

## Examples

See example Phoenix application [here](https://github.com/outerfaces/outerfaces_examples).


## Installation
Add `outerfaces` to your `mix.exs` dependencies:
```elixir
# mix.exs
def deps do
  [
    {:outerfaces, "~> 0.2.1"}
  ]
end
```
Then install and compile:
```bash
mix deps.get
mix compile
```

## Setup
Add to your application's supervision tree in `application.ex`:
```elixir
children = [
  HelloStarsWeb.Endpoint,
  Outerfaces.Endpoints.DefaultInitializer.supervisor(
    :hello_stars,
    HelloStarsWeb,
    ["hello_moon", "hello_stars"],
    []
  )
]
```

## Folder Structure
Organize your Phoenix app with projects under `lib/outerfaces/`:
```
| lib
| outerfaces
| - projects
| -- hello_moon
| --- index.html
| -- hello_stars
| --- index.html
```

## Build Static Files
Run the following to copy project files into `priv/`:
```bash
mix outerfaces.dist
```

## Advanced Configuration
See the default implementations for exampes of customization.

Create your own implementations creating your own versions of the following files within your project:
- [(Example) Default Dynamic Loader](https://github.com/outerfaces/outerfaces_ex_core/blob/main/lib/endpoints/dynamic_loader/default_dynamic_loader.ex)

- [(Example) Default Initializer](https://github.com/outerfaces/outerfaces_ex_core/blob/main/lib/endpoints/default_initializer.ex)

