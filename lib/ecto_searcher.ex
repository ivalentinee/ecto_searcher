defmodule EctoSearcher do
  @moduledoc """
  EctoSearcher is an attempt to bring dynamicly built queries (hello [Ransack](https://github.com/activerecord-hackery/ransack)) to the world of [Ecto](https://github.com/elixir-ecto/ecto).

  - `EctoSearcher.Searcher` — use this to search

  - `EctoSearcher.Sorter` — use this to sort

  - `EctoSearcher.Searcher.Mapping` — use this to implement custom searches

  - `EctoSearcher.Searcher.DefaultMapping` — use this if you don't want to implement custom mapping

  ## Usage
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
      search = %{"name_eq" => "Donald Trump", "description_cont" => "My president"}
      query = EctoSearcher.Searcher.search(MyMegaModel, search)
      MySuperApp.Repo.all(query)
    end
  end
  ```

  Advanced usage:
  ```elixir
  defmodule MySuperApp.CustomMapping do
    use EctoSearcher.Searcher.Mapping

    def matchers do
      custom_matchers = %{
        "not_eq" => fn field, value -> Query.dynamic([q], ^field != ^value) end
      }

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
  """
end
