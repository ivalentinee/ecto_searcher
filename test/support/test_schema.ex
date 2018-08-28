defmodule TestSchema do
  use Ecto.Schema

  schema "test_schema" do
    field(:test_field_one, :string)
    field(:test_field_two, :string)
    field(:custom_field, :naive_datetime)
  end
end
