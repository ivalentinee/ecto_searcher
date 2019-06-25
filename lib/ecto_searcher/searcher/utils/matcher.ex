defmodule EctoSearcher.Searcher.Utils.Matcher do
  @moduledoc false

  def lookup(field, matcher_name, value, mapping) do
    matchers = mapping.matchers

    if is_map(matchers) do
      matcher = matchers[matcher_name]

      matcher_query =
        case matcher do
          %{query: query} -> query
          anythong_else -> anythong_else
        end

      if is_function(matcher_query, 2) do
        matcher_query.(field, value)
      end
    end
  end
end
