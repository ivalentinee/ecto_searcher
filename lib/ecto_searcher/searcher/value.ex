defmodule EctoSearcher.Searcher.Value do
  @moduledoc nil

  alias Ecto.Type

  def cast(schema, field_name, value, condition_name, mapping) do
    type = field_type(schema, field_name, mapping)
    condition_aggregate_type = condition_aggregate_type(condition_name, mapping)
    cast_value(value, type, condition_aggregate_type)
  end

  defp field_type(schema, field_name, mapping) do
    fields = mapping.fields

    with true <- is_map(fields),
         true <- is_map(fields[field_name]),
         field_type <- fields[field_name][:type],
         false <- is_nil(field_type) do
      field_type
    else
      _ -> schema.__schema__(:type, field_name)
    end
  end

  defp condition_aggregate_type(condition_name, mapping) do
    conditions = mapping.conditions

    with true <- is_map(conditions),
         true <- is_map(conditions[condition_name]),
         condition_type <- conditions[condition_name][:aggregation],
         false <- is_nil(condition_type) do
      condition_type
    else
      _ -> nil
    end
  end

  defp cast_value(value, plain_type, condition_aggregate_type) do
    type =
      if condition_aggregate_type do
        {condition_aggregate_type, plain_type}
      else
        plain_type
      end

    case Type.cast(type, value) do
      {:ok, casted_value} -> casted_value
      _ -> value
    end
  end
end
