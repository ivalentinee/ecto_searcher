defmodule EctoSearcher.SampleModel do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sample_model" do
    field(:column_one, :string)
    field(:column_two, :string)
    field(:datetime_field, :naive_datetime)
    field(:integer_field, :integer)
    field(:uuid_field, Ecto.UUID)
  end

  def changeset(struct, params) do
    cast(struct, params, [:column_one, :column_two, :datetime_field, :integer_field, :uuid_field])
  end
end
