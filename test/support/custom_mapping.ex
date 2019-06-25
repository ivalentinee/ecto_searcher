defmodule CustomMapping do
  use EctoSearcher.Searcher.Mapping
  require Ecto.Query
  alias Ecto.Query

  def matchers do
    custom_mather = %{
      "not_eq" => fn field, value -> Query.dynamic([q], ^field != ^value) end
    }

    Map.merge(
      custom_mather,
      EctoSearcher.Searcher.DefaultMapping.matchers()
    )
  end

  def fields do
    %{
      datetime_field_as_date: %{
        query: Query.dynamic([q], fragment("?::date", q.datetime_field)),
        type: :date
      }
    }
  end
end
