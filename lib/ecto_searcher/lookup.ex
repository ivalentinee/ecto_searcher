defmodule EctoSearcher.Lookup do
  @moduledoc nil

  require Ecto.Query
  alias Ecto.Query

  def field_condition(field, condition, value, search_module) do
    lookup_search_module(search_module, :condition, [field, condition, value])
  end

  def field_query(field, search_module) do
    lookup_search_module(search_module, :query, [field]) || default_field_query(field)
  end

  def casted_value(schema, field_name, value, condition, search_module) do
    type = value_type(schema, field_name, search_module)
    aggregate_type = aggregate_type(condition, search_module)
    cast_value(value, type, aggregate_type)
  end

  defp default_field_query(field) do
    Query.dynamic([q], field(q, ^field))
  end

  defp value_type(schema, field_name, search_module) do
    lookup_search_module(search_module, :value_type, [field_name]) ||
      schema.__schema__(:type, field_name)
  end

  defp aggregate_type(condition, search_module) do
    lookup_search_module(search_module, :condition_aggregate_type, [condition])
  end

  defp cast_value(value, type, aggregate_type) do
    cond do
      type && aggregate_type ->
        aggregated_type = {aggregate_type, type}
        Query.dynamic([q], type(^value, ^aggregated_type))

      type ->
        Query.dynamic([q], type(^value, ^type))

      true ->
        value
    end
  end

  defp lookup_search_module(module_name, function_name, args) do
    apply(module_name, function_name, args)
  rescue
    FunctionClauseError -> nil
    UndefinedFunctionError -> nil
  end
end
