defmodule EctoSearcher.SearcherTest do
  # NOTE: tests heavily rely on inspect(ecto_query). Sorry. I know it's awful.
  #   http://alexkoppel.com/comparing-ecto-queries/ - this approach is no better I think

  use ExUnit.Case

  alias EctoSearcher.Searcher
  alias Ecto.Query
  require Query

  test "builds query for one field" do
    query =
      Searcher.search(
        TestSchema,
        %{"test_field_one" => %{"eq" => "some value"}},
        [:test_field_one]
      )

    expected_query = Query.from(t in TestSchema, where: t.test_field_one == ^"some value")

    assert inspect(expected_query) == inspect(query)
  end

  test "builds query for multiple conditions for one field" do
    query =
      Searcher.search(
        TestSchema,
        %{
          "test_field_one" => %{
            "gteq" => "0",
            "lteq" => "2"
          }
        },
        [:test_field_one]
      )

    expected_query =
      Query.from(t in TestSchema,
        where: t.test_field_one >= ^"0" and t.test_field_one <= ^"2"
      )

    assert inspect(expected_query) == inspect(query)
  end

  test "builds query for multiple fields" do
    query =
      Searcher.search(
        TestSchema,
        %{
          "test_field_one" => %{"eq" => "some value"},
          "test_field_two" => %{"eq" => "some other value"}
        },
        [:test_field_one, :test_field_two]
      )

    expected_query =
      Query.from(t in TestSchema,
        where: t.test_field_one == ^"some value" and t.test_field_two == ^"some other value"
      )

    assert inspect(expected_query) == inspect(query)
  end

  test "builds query with value interpolation" do
    query =
      Searcher.search(
        TestSchema,
        %{"test_field_one" => %{"cont" => 12345}},
        [:test_field_one]
      )

    expected_query = Query.from(t in TestSchema, where: ilike(t.test_field_one, ^"%12345%"))

    assert inspect(expected_query) == inspect(query)
  end

  test "ignores unpermitted fields" do
    query =
      Searcher.search(
        TestSchema,
        %{
          "test_field_one" => %{"eq" => "some value"},
          "test_field_two" => %{"eq" => "some other value"}
        },
        [:test_field_one]
      )

    expected_query = Query.from(t in TestSchema, where: t.test_field_one == ^"some value")

    assert inspect(expected_query) == inspect(query)
  end

  test "returns base_query for incorrect search_params" do
    query =
      Searcher.search(
        TestSchema,
        "something completely incorrect",
        [:test_field_one]
      )

    expected_query = Query.from(TestSchema)

    assert inspect(expected_query) == inspect(query)
  end

  test "ignores unknown conditions" do
    query =
      Searcher.search(
        TestSchema,
        %{
          "test_field_one" => %{"eq" => "some value"},
          "test_field_two" => %{"unknown_condition" => "some other value"}
        },
        [:test_field_one, :test_field_two]
      )

    expected_query = Query.from(t in TestSchema, where: t.test_field_one == ^"some value")

    assert inspect(expected_query) == inspect(query)
  end

  test "runs search with custom query, value cast and condition" do
    query =
      Searcher.search(
        TestSchema,
        %{
          "test_field_one" => %{"not_eq" => "some value"},
          "datetime_field_as_date" => %{"eq" => "2018-08-28"}
        },
        [:test_field_one, :datetime_field_as_date],
        TestCustomSearch
      )

    expected_query =
      Query.from(t in TestSchema,
        where:
          fragment("?::date", t.custom_field) == ^~D[2018-08-28] and
            t.test_field_one != ^"some value"
      )

    assert inspect(expected_query) == inspect(query)
  end

  test "runs search for aggregated condition" do
    query =
      Searcher.search(
        TestSchema,
        %{
          "integer_field" => %{"in" => ["0", "1", "2", "3"]}
        },
        [:integer_field]
      )

    field = Query.dynamic([q], field(q, :integer_field))
    value = Query.dynamic([q], ^[0, 1, 2, 3])
    where_condition = Query.dynamic([q], ^field in ^value)
    expected_query = Query.from(t in TestSchema, where: ^where_condition)

    assert inspect(expected_query) == inspect(query)
  end
end
