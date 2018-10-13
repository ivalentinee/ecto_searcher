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
  alias EctoSearcher.Lookup

  def search(
        schema,
        search_params,
        searchable_fields,
        search_module \\ EctoSearcher.DefaultSearchQueries
      )
      when is_list(searchable_fields) and is_atom(search_module) do
    base_query = Query.from(schema)
    search(base_query, schema, search_params, searchable_fields, search_module)
  end

  def search(
        base_query = %Ecto.Query{},
        schema,
        search_params,
        searchable_fields,
        search_module
      )
      when is_list(searchable_fields) and is_atom(search_module) do
    where_conditions =
      build_where_conditions(
        schema,
        search_params,
        searchable_fields,
        search_module
      )

    query = base_query || schema

    if is_nil(where_conditions) do
      query
    else
      Query.from(query, where: ^where_conditions)
    end
  end

  defp build_where_conditions(schema, search_params, searchable_fields, search_module) do
    search_params
    |> searchable_params(searchable_fields)
    |> Enum.map(fn search_param -> search_field(schema, search_param, search_module) end)
    |> compose_queries
  end

  defp search_field(schema, {field, conditions}, search_module) when is_map(conditions) do
    field_name_as_atom = String.to_existing_atom(field)
    field_query = Lookup.field(field_name_as_atom, search_module)

    conditions
    |> build_condition_queries(schema, field_query, field_name_as_atom, search_module)
    |> compose_queries()
  end

  defp search_field(_, _, _), do: nil

  defp build_condition_queries(conditions, schema, field, field_name, search_module) do
    Enum.map(conditions, fn {condition, value} ->
      casted_value = Lookup.cast_value(schema, field_name, value, condition, search_module)
      Lookup.condition(field, condition, casted_value, search_module)
    end)
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
