defmodule EctoSearcher.Sorter do
  @moduledoc """
  Module for sorting

  ## Usage
  sortable_fields = [:name, :description]
  sorted_query = EctoSearcher.Sorter.sort(SomeEctoModel, %{"field" => "name", "order" => "desc"}, sortable_fields)
  MySuperApp.Repo.all(sorted_query)
  """

  @allowed_order_values ["asc", "desc"]

  require Ecto.Query
  alias Ecto.Query

  def sort(base_query, %{"field" => field, "order" => order}, sortable_fields) when is_list(sortable_fields) do
    sortable_field_names = Enum.map(sortable_fields, &to_string/1)

    if field in sortable_field_names and order in @allowed_order_values do
      field_atom = String.to_existing_atom(field)
      order_atom = String.to_existing_atom(order)
      sorted_query(base_query, field_atom, order_atom)
    else
      base_query
    end
  end

  defp sorted_query(base_query, field, order) when is_atom(field) and is_atom(order) do
    Query.from(base_query, order_by: {^order, ^field})
  end
end
