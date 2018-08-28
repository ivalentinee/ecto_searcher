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

      def condition(field, {"eq", value}) do
        Query.dynamic([q], field(q, ^field) == ^value)
      end

      def condition(field, {"cont", value}) when is_binary(value) do
        Query.dynamic([q], ilike(field(q, ^field), ^"%#{value}%"))
      end

      def condition(field, {"in", value}) when is_list(value) do
        Query.dynamic([q], field(q, ^field) in ^value)
      end

      def condition(_field, {"in", _value}), do: nil

      def condition(field, {"gt", value}) do
        Query.dynamic([q], field(q, ^field) > ^value)
      end

      def condition(field, {"lt", value}) do
        Query.dynamic([q], field(q, ^field) < ^value)
      end

      def condition(field, {"gteq", value}) do
        Query.dynamic([q], field(q, ^field) >= ^value)
      end

      def condition(field, {"lteq", value}) do
        Query.dynamic([q], field(q, ^field) <= ^value)
      end

      def condition(field, {"overlaps", value}) when is_list(value) do
        Query.dynamic([q], fragment("? && ?", field(q, ^field), ^value))
      end
    end
  end
end
