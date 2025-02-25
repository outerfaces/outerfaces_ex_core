# Outerfaces Elixir Core

[![Hex.pm](https://img.shields.io/hexpm/v/outerfaces.svg)](https://hex.pm/packages/outerfaces)
[![HexDocs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/outerfaces)

This 'Outerfaces' core Elixir library contains helper modules for working with
"client-side" applications that live within a Phoenix web application,
and are served dynamically with the application at runtime by individual dedicated endpoints.

## What is Outerfaces?

Outerfaces is an experimental web framework that is built on top of Elixir + Phoenix.

It is designed to streamline web application development by integrating front-end and back-end workflows within a single codebase, while maintaining their separation.

This core library provides the necessary tools to integrate Outerfaces with your Phoenix application. These modules here are only starting points, and are expected to be extended and customized to fit your needs.

Outerfaces is still a hobby project and in early development, and as such is not recommended for production use.

There are accompanying libraries intended to be used with Outerfaces, such as a dependency-free Javascript Library for building functional front-end web applications using modern Javascript, and a quick-start examples project for quickly scaffolding a new client-side projects. These libraries are not (yet?) available publicly.

## Quick Start

### Folder Structure
Place the `/outerfaces/projects/` directory next to the `/lib/` directory in your Phoenix app.
```
config/
deps/
lib/
  ├── my_app/
  ├── my_app_web/
outerfaces/
  └── projects/
      ├── hello_world/
      │   └── index.html
      ├── hello_moon/
      │   └── index.html
      └── hello_stars/
          └── index.html
priv/
test/
```

### Application Configuration
The following simplified example shows a quick way to add dynamic endpoints for each of the projects in the `/outerfaces/projects/` directory:

```elixir
Add to your application's supervision tree in `application.ex`:
```elixir
children = [
  MyAppWeb.Endpoint,
  Outerfaces.Endpoints.DefaultInitializer.supervisor(
    :my_app,
    MyAppWeb,
    ["hello_world", "hello_moon", "hello_stars"],
    []
  )
]
```

### Advanced Configuration
Outerfaces application configuration, including specification for which projects to load, http configuration to use for the dynamic endpoints, etc should be placed in your application's configuration.

Alternatively, you can implement your own version of the `Outerfaces.Endpoints.DefaultInitializer` module to customize the initialization process, along with the `Outerfaces.Endpoints.DynamicLoader` module to customize the dynamic loading process.

See the default implementations for exampes of customization:

- [(Example) Default Dynamic Loader](https://github.com/outerfaces/outerfaces_ex_core/blob/main/lib/endpoints/dynamic_loader/default_dynamic_loader.ex)

- [(Example) Default Initializer](https://github.com/outerfaces/outerfaces_ex_core/blob/main/lib/endpoints/default_initializer.ex)

## "Building" Static Files
Run the following to copy all Outerfaces project files into `priv/`:
```bash
mix outerfaces.dist
```

## Examples

See example Phoenix application [here](https://github.com/outerfaces/outerfaces_examples).


## Installation
Add `outerfaces` to your `mix.exs` dependencies:
```elixir
# mix.exs
def deps do
  [
    {:outerfaces, "~> 0.2.3"}
  ]
end
```

Then install and compile:

```bash
mix deps.get
mix compile
```