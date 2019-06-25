defmodule EctoSearcher.Searcher.Utils.Value do
  @moduledoc false

  alias Ecto.Type
  alias EctoSearcher.Searcher.Utils.SearchQuery

  def cast(schema, search_query = %SearchQuery{}, mapping) do
    type = field_type(schema, search_query.field, mapping)
    matcher_aggregate_type = matcher_aggregate_type(search_query.matcher, mapping)
    cast_value(search_query.value, type, matcher_aggregate_type)
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

  defp matcher_aggregate_type(matcher_name, mapping) do
    matchers = mapping.matchers

    with true <- is_map(matchers),
         true <- is_map(matchers[matcher_name]),
         matcher_type <- matchers[matcher_name][:aggregation],
         false <- is_nil(matcher_type) do
      matcher_type
    else
      _ -> nil
    end
  end

  defp cast_value(value, plain_type, matcher_aggregate_type) do
    type =
      if matcher_aggregate_type do
        {matcher_aggregate_type, plain_type}
      else
        plain_type
      end

    case Type.cast(type, value) do
      {:ok, casted_value} -> casted_value
      _ -> value
    end
  end
end
