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
  alias EctoSearcher.Searcher.Utils.{Field, Value, Matcher, SearchCondition}

  @doc """
  Shortcut for `search/5`
  """
  def search(base_query, schema, search_params) do
    mapping = DefaultMapping
    search(base_query, schema, search_params, mapping)
  end

  @doc """
  Shortcut for `search/5`
  """
  def search(base_query, schema, search_params, searchable_fields)
      when is_list(searchable_fields) do
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

  `searchable_fields` is a list with fields (atoms) permitted for searching.
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
    searchable_fields = searchable_fields || Field.searchable_fields(schema, mapping)

    search_params
    |> SearchCondition.from_params(searchable_fields)
    |> Enum.reduce(base_query, fn search_condition, query_with_conditions ->
      put_condition(query_with_conditions, search_condition, schema, mapping)
    end)
  end

  defp put_condition(query, search_condition, schema, mapping) do
    field_query = Field.lookup(search_condition.field, schema, mapping)
    casted_value = Value.cast(search_condition, schema, mapping)
    match = Matcher.lookup(search_condition.matcher, mapping)

    if match && field_query do
      condition = match.(field_query, casted_value)
      Query.from(q in query, where: ^condition)
    else
      query
    end
  end
end
