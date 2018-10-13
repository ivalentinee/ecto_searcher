defmodule EctoSearcher.Lookup do
  @moduledoc nil

  require Ecto.Query
  alias Ecto.Query

  def condition(field, condition_name, value, search_module) do
    conditions = search_module.conditions

    if is_map(conditions) do
      condition = conditions[condition_name]

      condition_query =
        case condition do
          %{query: query} -> query
          anythong_else -> anythong_else
        end

      if is_function(condition_query, 2) do
        condition_query.(field, value)
      end
    end
  end

  def field(field_name, search_module) do
    fields = search_module.fields

    if is_map(fields) && fields[field_name] do
      field = fields[field_name]

      case field do
        %{query: query} -> query
        anythong_else -> anythong_else
      end
    else
      default_field_query(field_name)
    end
  end

  def cast_value(schema, field_name, value, condition_name, search_module) do
    type = field_type(schema, field_name, search_module)
    condition_aggregate_type = condition_aggregate_type(condition_name, search_module)
    cast_value(value, type, condition_aggregate_type)
  end

  defp condition_aggregate_type(condition_name, search_module) do
    conditions = search_module.conditions

    with true <- is_map(conditions),
         true <- is_map(conditions[condition_name]),
         condition_type <- conditions[condition_name][:aggregation],
         false <- is_nil(condition_type) do
      condition_type
    else
      _ -> nil
    end
  end

  defp default_field_query(field_name) do
    Query.dynamic([q], field(q, ^field_name))
  end

  defp field_type(schema, field_name, search_module) do
    fields = search_module.fields

    with true <- is_map(fields),
         true <- is_map(fields[field_name]),
         field_type <- fields[field_name][:type],
         false <- is_nil(field_type) do
      field_type
    else
      _ -> schema.__schema__(:type, field_name)
    end
  end

  defp cast_value(value, plain_type, condition_aggregate_type) do
    type =
      if condition_aggregate_type do
        {condition_aggregate_type, plain_type}
      else
        plain_type
      end

    case Ecto.Type.cast(type, value) do
      {:ok, casted_value} -> casted_value
      _ -> value
    end
  end
end
