# Ecto Searcher

[![Build Status](https://travis-ci.org/vemperor/ecto_searcher.svg?branch=master)](https://travis-ci.org/vemperor/ecto_searcher)

EctoSearcher is an attempt to bring dynamicly built queries (hello [Ransack](https://github.com/activerecord-hackery/ransack)) to the world of [Ecto](https://github.com/elixir-ecto/ecto).

If you plan on using this library you probably shouldn't.

If something doesn't work that's your problem, mkay?

~~No tests~~ Some tests, no real-world usage, nothing. Let's hope this piece of _software_ won't destroy you database.

## Installation

Add `ecto_searcher` from github to your mix.ex deps:

```elixir
def deps do
  [
    {:ecto_searcher, github: "vemperor/ecto_searcher"}
  ]
end
```

## Usage
First, we need examples, 'cause who needs a long good explanation.

Model:
```elixir
defmodule MyMegaModel do
  use Ecto.Schema
  # ... some ecto model code
end
```

### Searching
Basic usage:
```elixir
defmodule TotallyNotAPhoenixController do
  def not_some_controller_method() do
    searhable_fields = [:name, :description]
    search = %{"name" => %{"eq" => "Donald Trump"}, "description" => %{"cont" => "My president"}}
    query = EctoSearcher.Searcher.search(MyMegaModel, search, searchable_fields)
    MySuperApp.Repo.all(query)
  end
end
```

Advanced usage:
**TBD**

### Sorting
```elixir
defmodule TotallyNotAPhoenixController do
  def not_some_controller_method() do
    sortable_fields = [:name, :description]
    sort = %{"field" => "name", "order" => "desc"}
    query = EctoSearcher.Sorter.sort(MyMegaModel, sort, sortable_fields)
    MySuperApp.Repo.all(query)
  end
end
```

## Explanation
Just look the code.
