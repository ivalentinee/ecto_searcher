defmodule EctoSearcher do
  @moduledoc """
  EctoSearcher is an attempt to bring dynamicly built queries (hello [Ransack](https://github.com/activerecord-hackery/ransack)) to the world of [Ecto](https://github.com/elixir-ecto/ecto).

  ## Installation

  Add `ecto_searcher` from github to your mix.ex deps:

  ```elixir
  def deps do
    [
      {:ecto_searcher, "~> 0.2.0"}
    ]
  end
  ```

  ## Notice
  This package is build for sql queries and is tested with PostgreSQL. Every other usage may not work.

  ## Usage (short)
  - `EctoSearcher.Searcher` — use this to search
  - `EctoSearcher.Sorter` — use this to sort
  - `EctoSearcher.Searcher.Mapping` — use this to implement custom searches
  - `EctoSearcher.Searcher.DefaultMapping` — use this if you don't want to implement custom mapping

  ## Usage
  Obviously, EctoSearcher works on top of ecto schemas and ecto repos. It consumes ecto query and adds conditions built from input.

  Searching with `EctoSearcher.Searcher.search/5` and sorting `EctoSearcher.Searcher.sort/5` could be used separately or together.

  ### Searching
  To search use `EctoSearcher.Searcher.search/4` or `EctoSearcher.Searcher.search/5`:

  Basic usage:
  ```elixir
  defmodule TotallyNotAPhoenixController do
    def not_some_controller_method() do
      base_query = Ecto.Query.from(MyMegaModel)
      search = %{"name_eq" => "Donald Trump", "description_cont" => "My president"}
      query = EctoSearcher.Searcher.search(base_query, MyMegaModel, search)
      MySuperApp.Repo.all(query)
    end
  end
  ```

  In case you need to implement custom field queries or custom matchers you can implement custom Mapping:
  ```elixir
  defmodule MySuperApp.CustomMapping do
    use EctoSearcher.Searcher.Mapping

    def matchers do
      custom_matchers = %{
        "not_eq" => fn field, value -> Query.dynamic([q], ^field != ^value) end
      }

      ## No magic, just plain data manipulation
      Map.merge(
        custom_matchers,
        EctoSearcher.Searcher.DefaultMapping.matchers()
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
  ```

  And use it in `EctoSearcher.Searcher.search/5`:
  ```elixir
  defmodule TotallyNotAPhoenixContext do
    import Ecto.Query
    require Ecto.Query

    def not_some_context_method() do
      searchable_fields = [:name, :datetime_as_date, :description]
      search = %{
        "name_eq" => "Donald Trump",
        "datetime_as_date_gteq" => "2016-11-08", "datetime_as_date_lteq" => "2018-08-28",
        "description_not_eq" => "Not my president"
      }
      base_query = from(q in MyMegaModel, where: [q.id < 1984])
      query = EctoSearcher.Searcher.search(base_query, MyMegaModel, search, MySuperApp.CustomMapping, searchable_fields)
      MySuperApp.Repo.all(query)
    end
  end
  ```

  ### Sorting
  To sort use `EctoSearcher.Sorter.sort/3` or `EctoSearcher.Sorter.sort/5`:
  ```elixir
  defmodule TotallyNotAPhoenixController do
    def not_some_controller_method() do
      base_query = Ecto.Query.from(MyMegaModel)
      sort = %{"field" => "name", "order" => "desc"}
      query = EctoSearcher.Sorter.sort(base_query, MyMegaModel, sort)
      MySuperApp.Repo.all(query)
    end
  end
  ```

  Same as with searching you can implement custom mapping and use it in `EctoSearcher.Sorter.sort/5`:
  ```elixir
  defmodule MySuperApp.CustomMapping do
    use EctoSearcher.Searcher.Mapping

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
      sortable_fields = [:name, :datetime_as_date]

      sort = %{
        "field" => "datetime_as_date_gteq",
        "order" => "desc"
      }

      base_query = from(q in MyMegaModel, where: [q.id < 1984])
      query = EctoSearcher.Searcher.search(base_query, MyMegaModel, sort, MySuperApp.CustomMapping, sortable_fields)
      MySuperApp.Repo.all(query)
    end
  end
  ```
  """
end
