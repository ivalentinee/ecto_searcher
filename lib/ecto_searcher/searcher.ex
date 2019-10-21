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
  alias EctoSearcher.Mapping.Default
  alias EctoSearcher.Utils.{Field, Value, Matcher, SearchCondition}

  @type search_params() :: %{String.t() => String.t()}
  @type searchable_fields() :: [atom()]

  @doc """
  Shortcut for `search/5` with `EctoSearcher.Mapping.Default` as `mapping` and `nil` as `searchable_fields`
  """
  @spec search(Ecto.Queryable.t(), Ecto.Schema.t(), search_params()) :: Ecto.Queryable.t()
  def search(base_query, schema, search_params) do
    mapping = Default
    search(base_query, schema, search_params, mapping)
  end

  @doc """
  Shortcut for `search/5` with `EctoSearcher.Mapping.Default` as mapping
  """
  @spec search(Ecto.Queryable.t(), Ecto.Schema.t(), search_params(), searchable_fields()) ::
          Ecto.Queryable.t()
  def search(base_query, schema, search_params, searchable_fields)
      when is_list(searchable_fields) do
    mapping = Default
    search(base_query, schema, search_params, mapping, searchable_fields)
  end

  @doc """
  Builds search query

  `search_params` should be a map with search_fields in form of `"field_matcher"` like this:
  ```elixir
    %{
      "name_eq" => "Donald Trump",
      "description_cont" => "My president"
    }
  ```

  `mapping` should implement `EctoSearcher.Mapping` behavior. `EctoSearcher.Mapping.Default` provides some basics.

  `searchable_fields` is a list with fields (atoms) permitted for searching. If not provided (or `nil`) all fields are allowed for searching.
  """
  @spec search(
          Ecto.Queryable.t(),
          Ecto.Schema.t(),
          search_params(),
          module(),
          searchable_fields() | nil
        ) :: Ecto.Queryable.t()
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

    if match && field_query && casted_value do
      condition = match.(field_query, casted_value)
      Query.from(q in query, where: ^condition)
    else
      query
    end
  end
end
