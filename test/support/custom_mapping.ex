defmodule CustomMapping do
  use EctoSearcher.Searcher.Mapping
  require Ecto.Query
  alias Ecto.Query

  def conditions do
    custom_conditions = %{
      "not_eq" => fn field, value -> Query.dynamic([q], ^field != ^value) end
    }

    Map.merge(
      custom_conditions,
      EctoSearcher.Searcher.DefaultMapping.conditions()
    )
  end

  def fields do
    %{
      datetime_field_as_date: %{
        query: Query.dynamic([q], fragment("?::date", q.custom_field)),
        type: :date
      }
    }
  end
end
