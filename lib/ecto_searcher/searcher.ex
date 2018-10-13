defmodule EctoSearcher.Searcher do
  @moduledoc """
  Module for searching

  ## Usage
  ```elixir
  searhable_fields = [:name, :description]
  search = %{"name_eq" => "Donald Trump", "description_cont" => "My president"}
  query = EctoSearcher.Searcher.search(MyMegaModel, search, searchable_fields)
  MySuperApp.Repo.all(query)
  ```
  """

  require Ecto.Query
  alias Ecto.Query
  alias EctoSearcher.Searcher.Utils.{Field, Value, Condition, SearchQuery}

  @doc """
  Shortcut for `search/5`

  Takes `schema` as `base_query` and optional `mapping` (defaults to `EctoSearcher.Searcher.DefaultMapping`).
  """
  def search(
        schema,
        search_params,
        searchable_fields,
        mapping \\ EctoSearcher.Searcher.DefaultMapping
      )
      when is_list(searchable_fields) and is_atom(mapping) do
    base_query = Query.from(schema)
    search(base_query, schema, search_params, searchable_fields, mapping)
  end

  @doc """
  Builds search query

  Takes `%Ecto.Query{}` as `base_query` and ecto model as `schema`.

  `search_params` should be a map with search_fields in form of `"field_condition"` like this:
  ```elixir
    %{
      "name_eq" => "Donald Trump",
      "description_cont" => "My president"
    }
  ```

  `searchable_fields` should be a list of field names as atoms (looked up from schema or from `mapping.fields`):
  ```elixir
  [:name, :description]
  ```

  `mapping` should implement `EctoSearcher.Searcher.Mapping` behavior. `EctoSearcher.Searcher.DefaultMapping` provides some basics.
  """
  def search(
        base_query = %Ecto.Query{},
        schema,
        search_params,
        searchable_fields,
        mapping
      )
      when is_list(searchable_fields) and is_atom(mapping) do
    where_conditions =
      build_where_conditions(
        schema,
        search_params,
        searchable_fields,
        mapping
      )

    query = base_query || schema

    if is_nil(where_conditions) do
      query
    else
      Query.from(query, where: ^where_conditions)
    end
  end

  defp build_where_conditions(schema, search_params, searchable_fields, mapping)
       when is_map(search_params) do
    search_params
    |> SearchQuery.from_params(searchable_fields)
    |> Enum.map(fn search_query -> search_to_ecto_query(search_query, schema, mapping) end)
    |> compose_queries
  end

  defp build_where_conditions(_, _, _, _), do: []

  defp search_to_ecto_query(search_query, schema, mapping) do
    field_query = Field.lookup(search_query.field, mapping)

    casted_value =
      Value.cast(
        schema,
        search_query.field,
        search_query.value,
        search_query.condition,
        mapping
      )

    Condition.lookup(field_query, search_query.condition, casted_value, mapping)
  end

  defp compose_queries(queries) do
    if Enum.any?(queries) do
      queries
      |> Enum.reject(&is_nil/1)
      |> Enum.reduce(fn query, composition -> Query.dynamic(^composition and ^query) end)
    else
      nil
    end
  end
end
