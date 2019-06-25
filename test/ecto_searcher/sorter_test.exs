defmodule EctoSearcher.SorterTest do
  # NOTE: tests heavily rely on inspect(ecto_query). Sorry. I know it's awful.
  #   http://alexkoppel.com/comparing-ecto-queries/ - this approach is no better I think

  use ExUnit.Case

  alias EctoSearcher.Sorter
  alias Ecto.Query
  require Query

  test "builds asc sort query" do
    query =
      Sorter.sort(
        SampleModel,
        %{"field" => "column_one", "order" => "asc"}
      )

    expected_query =
      Query.from(t in SampleModel,
        order_by: [fragment("? ?", ^Query.dynamic([q], q.column_one), ^"asc")]
      )

    assert inspect(expected_query) == inspect(query)
  end

  test "builds asc sort query with custom field" do
    query =
      Sorter.sort(
        SampleModel,
        SampleModel,
        %{"field" => "datetime_field_as_date", "order" => "asc"},
        [:datetime_field_as_date],
        CustomMapping
      )

    expected_query =
      Query.from(t in SampleModel,
        order_by: [
          fragment("? ?", ^Query.dynamic([q], fragment("?::date", q.custom_field)), ^"asc")
        ]
      )

    assert inspect(expected_query) == inspect(query)
  end

  test "builds desc sort query" do
    query =
      Sorter.sort(
        SampleModel,
        SampleModel,
        %{"field" => "column_one", "order" => "desc"},
        [:column_one]
      )

    expected_query =
      Query.from(t in SampleModel,
        order_by: [fragment("? ?", ^Query.dynamic([q], q.column_one), ^"desc")]
      )

    assert inspect(expected_query) == inspect(query)
  end

  test "ignores unpermitted fields" do
    query =
      Sorter.sort(
        SampleModel,
        SampleModel,
        %{"field" => "column_one", "order" => "asc"},
        [:column_two]
      )

    expected_query = SampleModel

    assert inspect(expected_query) == inspect(query)
  end

  test "returns base_query for incorrect search_params" do
    query =
      Sorter.sort(
        SampleModel,
        SampleModel,
        "something completely incorrect",
        [:column_two]
      )

    expected_query = SampleModel

    assert inspect(expected_query) == inspect(query)
  end
end
