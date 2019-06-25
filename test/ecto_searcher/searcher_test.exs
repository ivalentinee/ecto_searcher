defmodule EctoSearcher.SearcherTest do
  # NOTE: tests heavily rely on inspect(ecto_query). Sorry. I know it's awful.
  #   http://alexkoppel.com/comparing-ecto-queries/ - this approach is no better I think

  use ExUnit.Case

  alias EctoSearcher.Factory
  alias EctoSearcher.SampleModel
  alias EctoSearcher.Searcher
  alias EctoSearcher.TestRepo
  alias Ecto.Query
  require Query

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(TestRepo)
  end

  test "finds records for one field" do
    base_query = Query.from(SampleModel)

    query =
      Searcher.search(
        base_query,
        SampleModel,
        %{"column_one_eq" => "some value"}
      )

    Factory.create_record(%{"column_one" => "some value"})
    Factory.create_record(%{"column_one" => "some other value"})

    found_records = TestRepo.all(query)

    assert 1 = Enum.count(found_records)
  end

  test "finds records for multiple matchers for one field" do
    base_query = Query.from(SampleModel)

    query =
      Searcher.search(
        base_query,
        SampleModel,
        %{
          "column_one_gteq" => "0",
          "column_one_lteq" => "2"
        },
        [:column_one]
      )

    Factory.create_record(%{"column_one" => "1"})
    Factory.create_record(%{"column_one" => "2"})
    Factory.create_record(%{"column_one" => "3"})

    found_records = TestRepo.all(query)

    assert 2 = Enum.count(found_records)
  end

  test "finds records for multiple fields" do
    base_query = Query.from(SampleModel)

    query =
      Searcher.search(
        base_query,
        SampleModel,
        %{
          "column_one_eq" => "some value",
          "column_two_eq" => "some other value"
        },
        [:column_one, :column_two]
      )

    Factory.create_record(%{"column_one" => "some value"})
    Factory.create_record(%{"column_two" => "some other value"})
    Factory.create_record(%{"column_one" => "some value", "column_two" => "some other value"})

    found_records = TestRepo.all(query)

    assert 1 = Enum.count(found_records)
  end

  test "finds records with ilike" do
    base_query = Query.from(SampleModel)

    query =
      Searcher.search(
        base_query,
        SampleModel,
        %{"column_one_cont" => "12345"},
        [:column_one]
      )

    Factory.create_record(%{"column_one" => "234"})
    Factory.create_record(%{"column_two" => "15"})
    Factory.create_record(%{"column_one" => "0123456"})

    found_records = TestRepo.all(query)

    assert 1 = Enum.count(found_records)
  end

  test "ignores unpermitted fields" do
    base_query = Query.from(SampleModel)

    query =
      Searcher.search(
        base_query,
        SampleModel,
        %{
          "column_one_eq" => "some value",
          "column_two_eq" => "some other value"
        },
        [:column_one]
      )

    Factory.create_record(%{"column_one" => "some value"})
    Factory.create_record(%{"column_two" => "some other value"})

    found_records = TestRepo.all(query)

    assert 1 = Enum.count(found_records)
  end

  test "returns all records for incorrect search_params" do
    base_query = Query.from(SampleModel)

    query =
      Searcher.search(
        base_query,
        SampleModel,
        "something completely incorrect"
      )

    Factory.create_record(%{"column_one" => "some value"})
    Factory.create_record(%{"column_two" => "some other value"})

    found_records = TestRepo.all(query)

    assert 2 = Enum.count(found_records)
  end

  test "ignores unknown matchers" do
    base_query = Query.from(SampleModel)

    query =
      Searcher.search(
        base_query,
        SampleModel,
        %{
          "column_one_eq" => "some value",
          "column_two_unknown_matcher" => "some other value"
        }
      )

    Factory.create_record(%{"column_one" => "some value"})
    Factory.create_record(%{"column_two" => "some other value"})

    found_records = TestRepo.all(query)

    assert 1 = Enum.count(found_records)
  end

  test "runs search with custom query, value cast and matcher" do
    base_query = Query.from(SampleModel)

    query =
      Searcher.search(
        base_query,
        SampleModel,
        %{
          "column_one_not_eq" => "some value",
          "datetime_field_as_date_eq" => "2018-08-28"
        },
        CustomMapping
      )

    Factory.create_record(%{
      "column_one" => "some other value",
      "datetime_field" => ~N[2018-08-28 12:13:14]
    })

    Factory.create_record(%{
      "column_one" => "and another value",
      "datetime_field" => ~N[2018-08-29 12:13:14]
    })

    found_records = TestRepo.all(query)

    assert 1 = Enum.count(found_records)
  end

  test "runs search for aggregated matcher" do
    base_query = Query.from(SampleModel)

    query =
      Searcher.search(
        base_query,
        SampleModel,
        %{
          "integer_field_in" => ["0", "1", "2", "3"]
        }
      )

    Factory.create_record(%{"integer_field" => 1})
    Factory.create_record(%{"integer_field" => 2})
    Factory.create_record(%{"integer_field" => 4})
    Factory.create_record(%{"integer_field" => 5})

    found_records = TestRepo.all(query)

    assert 2 = Enum.count(found_records)
  end
end
