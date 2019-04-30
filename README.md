# Ecto Searcher

[![Build Status](https://travis-ci.org/ivalentinee/ecto_searcher.svg?branch=master)](https://travis-ci.org/ivalentinee/ecto_searcher)

EctoSearcher is an attempt to bring dynamicly built queries (hello [Ransack](https://github.com/activerecord-hackery/ransack)) to the world of [Ecto](https://github.com/elixir-ecto/ecto).

If you plan on using this library you probably shouldn't.

If something doesn't work that's your problem, mkay?

~~No tests~~ Some tests, no real-world usage, nothing. Let's hope this piece of _software_ won't destroy you database.

## Installation

Add `ecto_searcher` from github to your mix.ex deps:

```elixir
def deps do
  [
    {:ecto_searcher, "0.1.1"}
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
    search = %{"name_eq" => "Donald Trump", "description_cont" => "My president"}
    query = EctoSearcher.Searcher.search(MyMegaModel, search, searchable_fields)
    MySuperApp.Repo.all(query)
  end
end
```

Advanced usage:
```elixir
defmodule MySuperApp.CustomMapping do
  use EctoSearcher.Searcher.Mapping

  def conditions do
    custom_conditions = %{
      "not_eq" => fn field, value -> Query.dynamic([q], ^field != ^value) end
    }

    Map.merge(
      custom_conditions,
      EctoSearcher.Searcher.DefaultMapping.conditions()
    )
  end

  def fields do
    %{
      datetime_field_as_date: %{
        query: Query.dynamic([q], fragment("?::date", q.custom_field)),
        type: :date
      }
    }
  end
end

defmodule TotallyNotAPhoenixContext do
  import Ecto.Query
  require Ecto.Query

  def not_some_context_method() do
    searhable_fields = [:name, :datetime_as_date, :description]
    search = %{
      "name_eq" => "Donald Trump",
      "datetime_as_date_gteq" => "2016-11-08", "datetime_as_date_lteq" => "2018-08-28",
      "description_not_eq" => "Not my president"
    }
    base_query = from(q in MyMegaModel, where: [q.id < 1984])
    query = EctoSearcher.Searcher.search(base_query, MyMegaModel, search, searchable_fields, MySuperApp.CustomMapping)
    MySuperApp.Repo.all(query)
  end
end
```

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
Just look the code. Or usage. Or both.
