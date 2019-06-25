defmodule EctoSearcher.Searcher.Utils.Matcher do
  @moduledoc false

  def lookup(matcher_name, mapping) do
    matchers = mapping.matchers

    if is_map(matchers) do
      matcher = matchers[matcher_name]

      matcher_query =
        case matcher do
          %{query: query} -> query
          anything_else -> anything_else
        end

      if is_function(matcher_query, 2) do
        matcher_query
      end
    end
  end
end
