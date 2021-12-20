defmodule EctoSearcher.TestRepo.Migrations.CreateSampleModel do
  use Ecto.Migration

  def change do
    create table(:sample_model) do
      add(:column_one, :string)
      add(:column_two, :string)
      add(:datetime_field, :timestamp)
      add(:integer_field, :integer)
      add(:uuid_field, :uuid)
    end
  end
end
