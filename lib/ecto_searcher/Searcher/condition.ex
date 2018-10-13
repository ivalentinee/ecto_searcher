defmodule EctoSearcher.Searcher.Condition do
  @moduledoc nil

  require Ecto.Query
  alias Ecto.Query

  def lookup(field, condition_name, value, search_module) do
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
end
