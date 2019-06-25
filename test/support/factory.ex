defmodule EctoSearcher.Factory do
  alias EctoSearcher.TestRepo
  alias EctoSearcher.SampleModel

  def create_record(params \\ %{}) do
    changeset = SampleModel.changeset(%SampleModel{}, params)
    TestRepo.insert(changeset)
  end
end
