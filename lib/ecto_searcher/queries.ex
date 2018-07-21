defmodule EctoSearcher.Queries do
  @moduledoc """
  Contains default queries

  ## Usage
  ```elixir
  defmodule CustomSearcher
  use EctoSearcher.Queries
  # your custom queries go here
  end
  ```

  ## Queries
  - `eq` — equality (`field == value`)
  - `cont` — contains substring (`ilike(field, value)`)
  - `in` — inclusion (`field in value`)
  - `gt` — greater than (`field > value`)
  - `gteq` — greater than or equal (`field >= value`)
  - `lt` — less than (`field < value`)
  - `lteq` — less than or equal (`field <= value`)
  """

  defmacro __using__(_) do
    quote do
      require Ecto.Query
      alias Ecto.Query

      def query(field, {"eq", value}) do
        Query.dynamic([q], field(q, ^field) == ^value)
      end

      def query(field, {"cont", value}) when is_binary(value) do
        Query.dynamic([q], ilike(field(q, ^field), ^"%#{value}%"))
      end

      def query(field, {"in", value}) when is_list(value) do
        Query.dynamic([q], field(q, ^field) in ^value)
      end

      def query(_field, {"in", _value}), do: nil

      def query(field, {"gt", value}) do
        Query.dynamic([q], field(q, ^field) > ^value)
      end

      def query(field, {"lt", value}) do
        Query.dynamic([q], field(q, ^field) < ^value)
      end

      def query(field, {"gteq", value}) do
        Query.dynamic([q], field(q, ^field) >= ^value)
      end

      def query(field, {"lteq", value}) do
        Query.dynamic([q], field(q, ^field) <= ^value)
      end
    end
  end
end
