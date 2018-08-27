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

Basic usage:
```elixir
defmodule TotallyNotAPhoenixController do
  def not_some_controller_method() do
    searhable_fields = [:name, :description]
    search = %{"name" => %{"eq" => "Donald Trump"}, "description" => %{"cont" => "My president"}}
    query = EctoSearcher.search(MyMegaModel, search, searchable_fields)
    MySuperApp.Repo.all(query)
  end
end
```

Advanced usage:
```elixir
defmodule MySuperApp.CustomSearches do
  use EctoSearcher.Queries

  # You can define custom queries here! Wow! So impressive!
  def query(:description_does_not_contain, value) do
    Query.dynamic([q], not ilike(q.description, ^"%#{value}%"))
  end
end

defmodule TotallyNotAPhoenixContext do
  import Ecto.Query
  require Ecto.Query

  def not_some_context_method() do
    searhable_fields = [:name, :description_does_not_contain]
    search = %{"name" => %{"eq" => "Donald Trump"}, "description_does_not_contain" => "Not my president"}
    base_query = from(q in MyMegaModel, where: [q.id < 1984])
    query = EctoSearcher.search(base_query, search, searchable_fields, MySuperApp.CustomSearches)
    MySuperApp.Repo.all(query)
  end
end
```

## Explanation
Just look the code. It's under 200 lines.
