defmodule EctoSearcher.Query do
  @moduledoc nil

  require Ecto.Query
  alias Ecto.Query

  def field_query(field, search_module) do
    try do
      search_module.query(field)
    rescue
      FunctionClauseError -> default_value_query(field)
      UndefinedFunctionError -> default_value_query(field)
    end
  end

  defp default_value_query(field) do
    Query.dynamic([q], field(q, ^field))
  end
end
