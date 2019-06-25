defmodule EctoSearcher.Sorter do
  @moduledoc """
  Module for sorting

  ## Usage
  ```elixir
  sortable_fields = [:name, :description]
  sorted_query = EctoSearcher.Sorter.sort(SomeEctoModel, %{"field" => "name", "order" => "desc"}, sortable_fields)
  MySuperApp.Repo.all(sorted_query)
  ```
  """

  @allowed_order_values ["asc", "desc"]

  require Ecto.Query
  alias Ecto.Query
  alias EctoSearcher.Searcher.DefaultMapping
  alias EctoSearcher.Searcher.Utils.Field

  @doc """
  Shortcut for `sort/5`
  """
  def sort(base_query, schema, sort_query) do
    sortable_fields = Field.searchable_fields(schema, DefaultMapping)
    mapping = DefaultMapping

    sort(base_query, schema, sort_query, mapping, sortable_fields)
  end

  @doc """
  Builds sort query

  Takes `%Ecto.Query{}` as `base_query` and ecto model as `schema`.

  `sort_params` should be a map with "field" and "order" like this:
  ```elixir
    %{
      "field" => "name",
      "order" => "asc"
    }
  ```

  ```elixir
  [:name, :description]
  ```

  `mapping` should implement `EctoSorter.Sorter.Mapping` behavior. `EctoSorter.Sorter.DefaultMapping` provides some basics.

  `searchable_fields` is a list with fields (atoms) permitted for searching.
  """
  def sort(
        base_query,
        schema,
        sort_query,
        mapping,
        sortable_fields \\ nil
      )
      when is_list(sortable_fields) or is_nil(sortable_fields) do
    sortable_fields = sortable_fields || Field.searchable_fields(schema, mapping)

    case sort_query do
      %{"field" => field, "order" => order} ->
        sorted_query(base_query, field, order, schema, mapping, sortable_fields)

      _ ->
        base_query
    end
  end

  defp sorted_query(base_query, field, order, schema, mapping, sortable_fields) do
    sortable_field_names = Enum.map(sortable_fields, &to_string/1)

    if field in sortable_field_names and order in @allowed_order_values do
      field_atom = String.to_existing_atom(field)
      field_query = Field.lookup(field_atom, schema, mapping)

      order_by =
        case order do
          "asc" -> [asc: field_query]
          "desc" -> [desc: field_query]
        end

      Query.from(base_query, order_by: ^order_by)
    else
      base_query
    end
  end
end
