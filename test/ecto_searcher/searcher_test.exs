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
            "gteq" => 0,
            "lteq" => 2
          }
        },
        [:test_field_one]
      )

    expected_query =
      Query.from(t in TestSchema, where: t.test_field_one >= ^0 and t.test_field_one <= ^2)

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
end