defmodule EctoSearcher.Lookup do
  @moduledoc nil

  require Ecto.Query
  alias Ecto.Query

  def field_condition(field, condition, value, search_module) do
    try do
      search_module.condition(field, condition, value)
    rescue
      FunctionClauseError -> nil
    end
  end

  def field_query(field, search_module) do
    try do
      search_module.query(field)
    rescue
      FunctionClauseError -> default_field_query(field)
      UndefinedFunctionError -> default_field_query(field)
    end
  end

  def casted_value(schema, field_name, value, search_module) do
    try do
      search_module.cast_value(field_name, value)
    rescue
      FunctionClauseError -> cast_value_to_schema_type(schema, field_name, value)
      UndefinedFunctionError -> cast_value_to_schema_type(schema, field_name, value)
    end
  end

  defp default_field_query(field) do
    Query.dynamic([q], field(q, ^field))
  end

  defp cast_value_to_schema_type(schema, field_name, value) do
    schema_type = schema.__schema__(:type, field_name)

    if schema_type do
      Query.dynamic([q], type(^value, ^schema_type))
    else
      value
    end
  end
end
