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

  def sort(base_query, sort_query, sortable_fields)
      when is_list(sortable_fields) do
    case sort_query do
      %{"field" => field, "order" => order} ->
        sorted_query(base_query, field, order, sortable_fields)

      _ ->
        base_query
    end
  end

  defp sorted_query(base_query, field, order, sortable_fields) do
    sortable_field_names = Enum.map(sortable_fields, &to_string/1)

    if field in sortable_field_names and order in @allowed_order_values do
      field_atom = String.to_existing_atom(field)
      order_atom = String.to_existing_atom(order)
      Query.from(base_query, order_by: {^order_atom, ^field_atom})
    else
      base_query
    end
  end
end
