defmodule EctoSearcher.Mapping.Default do
  use EctoSearcher.Mapping
  require Ecto.Query
  alias Ecto.Query

  @moduledoc """
  Provides default matcher mapping.

  ## Matchers
  - `eq` — equality (`field == value`)
  - `cont` — contains substring (`ilike(field, value)`)
  - `in` — inclusion (`field in value`)
  - `gt` — greater than (`field > value`)
  - `gteq` — greater than or equal (`field >= value`)
  - `lt` — less than (`field < value`)
  - `lteq` — less than or equal (`field <= value`)
  - `overlaps` — arrays overlap (`field && value`)
  """

  def matchers do
    %{
      "eq" => fn field, value -> Query.dynamic([q], ^field == ^value) end,
      "cont" => fn field, value ->
        Query.dynamic([q], ilike(fragment("?::varchar", ^field), ^"%#{value}%"))
      end,
      "gt" => fn field, value -> Query.dynamic([q], ^field > ^value) end,
      "lt" => fn field, value -> Query.dynamic([q], ^field < ^value) end,
      "gteq" => fn field, value -> Query.dynamic([q], ^field >= ^value) end,
      "lteq" => fn field, value -> Query.dynamic([q], ^field <= ^value) end,
      "overlaps" => fn field, value -> Query.dynamic([q], fragment("? && ?", ^field, ^value)) end,
      "in" => %{
        query: fn field, value -> Query.dynamic([q], ^field in ^value) end,
        aggregation: :array
      }
    }
  end
end
