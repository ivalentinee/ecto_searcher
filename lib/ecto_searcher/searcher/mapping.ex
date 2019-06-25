defmodule EctoSearcher.Searcher.Mapping do
  @moduledoc """
  Behaviour for search query, matcher and field mappings

  ## Usage
  Either adopt `EctoSearcher.Searcher.Mapping` behaviour and implement callbacks or `use EctoSearcher.Searcher.Mapping`, which provides defaults.

  ```elixir
  defmodule CustomMapping do
    use EctoSearcher.Searcher.Mapping
    require Ecto.Query
    alias Ecto.Query

    def matchers
      %{
        "not_eq" => fn(field, value) -> Query.dynamic([q], ^field != ^value) end
      }
    end
  end
  ```
  """

  @doc """
  Should return map with search matchers

  Search matcher map should look like:
  ```elixir
  %{
    "not_eq" => fn(field, value) -> Query.dynamic([q], ^field != ^value) end
    "in" => %{
      query: fn field, value -> Query.dynamic([q], ^field in ^value) end,
      aggregation: :array
    }
  }
  ```

  Matcher name will be matched as search field suffix.

  Values should either be a query function or a map with query function as `:query` and value aggregate type as `:aggregation`.

  Query function will be called with arguments `field` (`atom`) and `value` (casted to specific type) and should return `Ecto.Query.DynamicExpr`.
  """
  @callback matchers() :: Map.t()
  @doc """
  Should return map with field queries

  Field queries map should look like:
  ```elixir
  %{
    id_alias: Query.dynamic([q], q.id),
    datetime_field_as_date: %{
      query: Query.dynamic([q], fragment("?::date", q.datetime_field)),
      type: :date
    }
  }
  ```

  Field name will be matched as search field prefix (from `searchable_fields`).

  Values should either be a `Ecto.Query.DynamicExpr` or a map with `Ecto.Query.DynamicExpr` as `:query` and value type as `:type`.
  """
  @callback fields() :: Map.t()

  defmacro __using__(_) do
    quote do
      @behaviour EctoSearcher.Searcher.Mapping

      @doc """
      Callback implementation for `EctoSearcher.Searcher.Mapping.matchers/0`
      """
      def matchers, do: %{}

      @doc """
      Callback implementation for `EctoSearcher.Searcher.Mapping.fields/0`
      """
      def fields, do: %{}

      defoverridable matchers: 0, fields: 0
    end
  end
end
