defmodule EctoSearcher do
  @moduledoc nil

  require Ecto.Query
  alias Ecto.Query

  def search(
        base_query,
        search_params,
        searchable_fields,
        queries_module \\ EctoSearcher.DefaultSearcher
      )
      when is_map(search_params) and is_list(searchable_fields) do
    searchable_field_names = Enum.map(searchable_fields, &to_string/1)

    searchable_params =
      Enum.filter(search_params, fn {key, _} -> key in searchable_field_names end)

    queries = build_search_queries(searchable_params, queries_module)
    query_composition = compose_queries(queries)
    Query.from(base_query, where: ^query_composition)
  end

  defp build_search_queries(search_params, queries_module) do
    Enum.map(search_params, fn search_param ->
      search_field(search_param, queries_module)
    end)
  end

  defp search_field({field, conditions}, queries_module) do
    field_name_as_atom = String.to_existing_atom(field)

    if is_map(conditions) do
      conditions
      |> build_condition_queries(field_name_as_atom, queries_module)
      |> compose_queries()
    else
      run_query_on_field(field_name_as_atom, conditions, queries_module)
    end
  end

  defp build_condition_queries(conditions, field, queries_module) do
    Enum.map(conditions, fn condition ->
      run_query_on_field(field, condition, queries_module)
    end)
  end

  defp run_query_on_field(field, condition, queries_module) do
    try do
      queries_module.query(field, condition)
    rescue
      FunctionClauseError -> nil
    end
  end

  defp compose_queries(queries) do
    if Enum.any?(queries) do
      queries
      |> Enum.reject(&is_nil/1)
      |> Enum.reduce(fn query, composition -> Query.dynamic(^query and ^composition) end)
    else
      []
    end
  end
end
