defmodule EctoSearcher.Conditions do
  @moduledoc """
  Contains default queries

  ## Usage
  ```elixir
  defmodule CustomSearcher
  use EctoSearcher.Queries
  # your custom queries go here
  end
  ```

  ## Conditions
  - `eq` — equality (`field == value`)
  - `cont` — contains substring (`ilike(field, value)`)
  - `in` — inclusion (`field in value`)
  - `gt` — greater than (`field > value`)
  - `gteq` — greater than or equal (`field >= value`)
  - `lt` — less than (`field < value`)
  - `lteq` — less than or equal (`field <= value`)
  - `overlaps` — arrays overlap (`field && value`)
  """

  defmacro __using__(_) do
    quote do
      require Ecto.Query
      alias Ecto.Query

      def condition(field, "eq", value) do
        Query.dynamic([q], ^field == ^value)
      end

      def condition(field, "cont", value) do
        Query.dynamic([q], ilike(^field, ^"%#{value}%"))
      end

      def condition(field, "in", value) do
        Query.dynamic([q], ^field in ^value)
      end

      def condition(field, "gt", value) do
        Query.dynamic([q], ^field > ^value)
      end

      def condition(field, "lt", value) do
        Query.dynamic([q], ^field < ^value)
      end

      def condition(field, "gteq", value) do
        Query.dynamic([q], ^field >= ^value)
      end

      def condition(field, "lteq", value) do
        Query.dynamic([q], ^field <= ^value)
      end

      def condition(field, "overlaps", value) do
        Query.dynamic([q], fragment("? && ?", ^field, ^value))
      end

      def condition_aggregate_type("in") do
        :array
      end
    end
  end
end
