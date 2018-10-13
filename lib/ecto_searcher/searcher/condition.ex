defmodule EctoSearcher.Searcher.Condition do
  @moduledoc nil

  def lookup(field, condition_name, value, mapping) do
    conditions = mapping.conditions

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
end
