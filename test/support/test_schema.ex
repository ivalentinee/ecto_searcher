defmodule TestSchema do
  use Ecto.Schema

  schema "test_schema" do
    field(:test_field_one, :string)
    field(:test_field_two, :string)
    field(:datetime_field, :naive_datetime)
    field(:integer_field, :integer)
  end
end
