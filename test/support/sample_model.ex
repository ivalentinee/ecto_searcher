defmodule EctoSearcher.SampleModel do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sample_model" do
    field(:column_one, :string)
    field(:column_two, :string)
    field(:datetime_field, :naive_datetime)
    field(:integer_field, :integer)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:column_one, :column_two, :datetime_field, :integer_field])
  end
end
