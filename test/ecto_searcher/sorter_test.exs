defmodule EctoSearcher.SorterTest do
  # NOTE: tests heavily rely on inspect(ecto_query). Sorry. I know it's awful.
  #   http://alexkoppel.com/comparing-ecto-queries/ - this approach is no better I think

  use ExUnit.Case

  alias Ecto.Query
  require Query

  test "builds asc sort query" do
    query =
      EctoSearcher.Sorter.sort(
        TestSchema,
        %{"field" => "test_field_one", "order" => "asc"},
        [:test_field_one]
      )

    expected_query = Query.from(t in TestSchema, order_by: [asc: t.test_field_one])

    assert inspect(expected_query) == inspect(query)
  end

  test "builds desc sort query" do
    query =
      EctoSearcher.Sorter.sort(
        TestSchema,
        %{"field" => "test_field_one", "order" => "desc"},
        [:test_field_one]
      )

    expected_query = Query.from(t in TestSchema, order_by: [desc: t.test_field_one])

    assert inspect(expected_query) == inspect(query)
  end

  test "ignores unpermitted fields" do
    query =
      EctoSearcher.Sorter.sort(
        TestSchema,
        %{"field" => "test_field_one", "order" => "asc"},
        [:test_field_two]
      )

    expected_query = TestSchema

    assert inspect(expected_query) == inspect(query)
  end

  test "returns base_query for incorrect search_params" do
    query =
      EctoSearcher.Sorter.sort(
        TestSchema,
        "something completely incorrect",
        [:test_field_two]
      )

    expected_query = TestSchema

    assert inspect(expected_query) == inspect(query)
  end
end
