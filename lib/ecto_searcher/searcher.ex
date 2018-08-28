defmodule EctoSearcher.Searcher do
  @moduledoc """
  Module for searching

  ## Usage
  searhable_fields = [:name, :description]
  search = %{"name" => %{"eq" => "Donald Trump"}, "description" => %{"cont" => "My president"}}
  query = EctoSearcher.Searcher.search(MyMegaModel, search, searchable_fields)
  MySuperApp.Repo.all(query)
  """

  require Ecto.Query
  alias Ecto.Query

  def search(
        base_query,
        search_params,
        searchable_fields,
        search_module \\ EctoSearcher.DefaultSearch
      )
      when is_list(searchable_fields) do
    where_conditions = build_where_conditions(search_params, searchable_fields, search_module)

    if is_nil(where_conditions) do
      base_query
    else
      Query.from(base_query, where: ^where_conditions)
    end
  end

  defp build_where_conditions(search_params, searchable_fields, search_module) do
    search_params
    |> searchable_params(searchable_fields)
    |> Enum.map(fn search_param -> search_field(search_param, search_module) end)
    |> compose_queries
  end

  defp search_field({field, conditions}, search_module) do
    field_name_as_atom = String.to_existing_atom(field)

    if is_map(conditions) do
      conditions
      |> build_condition_queries(field_name_as_atom, search_module)
      |> compose_queries()
    else
      run_condition_on_field(field_name_as_atom, conditions, search_module)
    end
  end

  defp build_condition_queries(conditions, field, search_module) do
    Enum.map(conditions, fn condition ->
      run_condition_on_field(field, condition, search_module)
    end)
  end

  defp run_condition_on_field(field, condition, search_module) do
    try do
      search_module.condition(field, condition)
    rescue
      FunctionClauseError -> nil
    end
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

  defp searchable_params(search_params, searchable_fields) when is_map(search_params) do
    searchable_field_names = Enum.map(searchable_fields, &to_string/1)
    Enum.filter(search_params, fn {key, _} -> key in searchable_field_names end)
  end

  defp searchable_params(_, _), do: %{}
end
