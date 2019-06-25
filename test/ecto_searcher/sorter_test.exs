defmodule EctoSearcher.SorterTest do
  # NOTE: tests heavily rely on inspect(ecto_query). Sorry. I know it's awful.
  #   http://alexkoppel.com/comparing-ecto-queries/ - this approach is no better I think

  use ExUnit.Case

  alias EctoSearcher.Factory
  alias EctoSearcher.SampleModel
  alias EctoSearcher.Sorter
  alias EctoSearcher.TestRepo
  alias Ecto.Query
  require Query

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(TestRepo)
  end

  test "sorts asc" do
    query =
      Sorter.sort(
        SampleModel,
        %{"field" => "column_one", "order" => "asc"}
      )

    {:ok, record_1} = Factory.create_record(%{"column_one" => "5"})
    {:ok, record_2} = Factory.create_record(%{"column_one" => "2"})
    {:ok, _record_3} = Factory.create_record(%{"column_one" => "4"})
    {:ok, _record_4} = Factory.create_record(%{"column_one" => "3"})

    found_records = TestRepo.all(query)

    assert record_2.id == List.first(found_records).id
    assert record_1.id == List.last(found_records).id
  end

  test "sorts desc" do
    query =
      Sorter.sort(
        SampleModel,
        SampleModel,
        %{"field" => "column_one", "order" => "desc"},
        [:column_one]
      )

    {:ok, record_1} = Factory.create_record(%{"column_one" => "5"})
    {:ok, record_2} = Factory.create_record(%{"column_one" => "2"})
    {:ok, _record_3} = Factory.create_record(%{"column_one" => "4"})
    {:ok, _record_4} = Factory.create_record(%{"column_one" => "3"})

    found_records = TestRepo.all(query)

    assert record_1.id == List.first(found_records).id
    assert record_2.id == List.last(found_records).id
  end

  test "sorts with custom field" do
    query =
      Sorter.sort(
        SampleModel,
        SampleModel,
        %{"field" => "datetime_field_as_date", "order" => "asc"},
        [:datetime_field_as_date],
        CustomMapping
      )

    Factory.create_record(%{
      "column_one" => "some other value",
      "datetime_field" => ~N[2018-08-28 12:13:14]
    })

    {:ok, record_1} = Factory.create_record(%{"datetime_field" => ~N[2018-08-30 12:13:14]})
    {:ok, record_2} = Factory.create_record(%{"datetime_field" => ~N[2018-08-20 12:13:14]})
    {:ok, _record_3} = Factory.create_record(%{"datetime_field" => ~N[2018-08-25 12:13:14]})
    {:ok, _record_4} = Factory.create_record(%{"datetime_field" => ~N[2018-08-23 12:13:14]})

    found_records = TestRepo.all(query)

    assert record_2.id == List.first(found_records).id
    assert record_1.id == List.last(found_records).id
  end

  test "returns unsorted records for incorrect sort_params" do
    query =
      Sorter.sort(
        SampleModel,
        SampleModel,
        "something completely incorrect",
        [:column_one]
      )

    Factory.create_record(%{"column_one" => "2"})
    Factory.create_record(%{"column_one" => "1"})

    found_records = TestRepo.all(query)

    assert 2 = Enum.count(found_records)
  end
end
