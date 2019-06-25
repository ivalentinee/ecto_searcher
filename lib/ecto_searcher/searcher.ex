defmodule EctoSearcher.Searcher do
  @moduledoc """
  Module for searching

  ## Usage
  ```elixir
  search = %{"name_eq" => "Donald Trump", "description_cont" => "My president"}
  query = EctoSearcher.Searcher.search(MyMegaModel, search)
  MySuperApp.Repo.all(query)
  ```
  """

  require Ecto.Query
  alias Ecto.Query
  alias EctoSearcher.Searcher.DefaultMapping
  alias EctoSearcher.Searcher.Utils.{Field, Value, Matcher, SearchQuery}

  @doc """
  Shortcut for `search/5`

  Takes `schema` as `base_query`, searhable_fields as `schema` fields and `mapping` as `EctoSearcher.Searcher.DefaultMapping`.
  """
  def search(schema, search_params) do
    base_query = Query.from(schema)
    mapping = DefaultMapping
    search(base_query, schema, search_params, mapping)
  end

  @doc """
  Shortcut for `search/5`

  Takes `schema` as `base_query`.
  """
  def search(schema, search_params, mapping) when is_atom(mapping) do
    base_query = Query.from(schema)
    search(base_query, schema, search_params, mapping)
  end

  @doc """
  Shortcut for `search/5`

  Takes `schema` as `base_query`.
  """
  def search(schema, search_params, searchable_fields) when is_list(searchable_fields) do
    base_query = Query.from(schema)
    mapping = DefaultMapping
    search(base_query, schema, search_params, mapping, searchable_fields)
  end

  @doc """
  Builds search query

  Takes `%Ecto.Query{}` as `base_query` and ecto model as `schema`.

  `search_params` should be a map with search_fields in form of `"field_matcher"` like this:
  ```elixir
    %{
      "name_eq" => "Donald Trump",
      "description_cont" => "My president"
    }
  ```

  `mapping` should implement `EctoSearcher.Searcher.Mapping` behavior. `EctoSearcher.Searcher.DefaultMapping` provides some basics.
  """
  def search(base_query = %Ecto.Query{}, schema, search_params, mapping, searchable_fields \\ nil)
      when is_atom(mapping) do
    if is_map(search_params) do
      build_query(base_query, schema, search_params, mapping, searchable_fields)
    else
      base_query
    end
  end

  defp build_query(base_query, schema, search_params, mapping, searchable_fields) do
    searchable_fields =
      if searchable_fields do
        searchable_fields
      else
        schema.__schema__(:fields) ++ Map.keys(mapping.fields)
      end

    search_params
    |> SearchQuery.from_params(searchable_fields)
    |> Enum.reduce(base_query, fn search_query, query_with_matchers ->
      ecto_query = search_to_ecto_query(search_query, schema, mapping)

      if ecto_query do
        Query.where(query_with_matchers, ^ecto_query)
      else
        query_with_matchers
      end
    end)
  end

  defp search_to_ecto_query(search_query, schema, mapping) do
    field_query = Field.lookup(search_query.field, mapping)
    casted_value = Value.cast(schema, search_query, mapping)
    matcher = Matcher.lookup(field_query, search_query.matcher, mapping)

    if matcher do
      matcher.(field_query, casted_value)
    else
      nil
    end
  end
end
