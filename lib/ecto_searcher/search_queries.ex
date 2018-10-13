defmodule EctoSearcher.SearchQueries do
  @callback queries() :: Map.t()
  @callback conditions() :: Map.t()
  @callback fields() :: Map.t()

  defmacro __using__(_) do
    quote do
      @behaviour EctoSearcher.SearchQueries

      def queries, do: %{}
      def conditions, do: %{}
      def fields, do: %{}

      defoverridable queries: 0, conditions: 0, fields: 0
    end
  end
end
