defmodule TestCustomSearch do
  use EctoSearcher.Conditions

  def query(:custom_field_as_date) do
    Query.dynamic([q], fragment("?::date", q.custom_field))
  end

  def value_type(:custom_field_as_date), do: :date

  def condition(field, "not_eq", value) do
    Query.dynamic([q], ^field != ^value)
  end
end
