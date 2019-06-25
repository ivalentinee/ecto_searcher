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
    sortable_fields = schema.__schema__(:fields)
    mapping = DefaultMapping

    sort(base_query, schema, sort_query, sortable_fields, mapping)
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

  `sortable_fields` should be a list of field names as atoms (looked up from schema or from `mapping.fields`):
  ```elixir
  [:name, :description]
  ```

  `mapping` should implement `EctoSorter.Sorter.Mapping` behavior. `EctoSorter.Sorter.DefaultMapping` provides some basics.
  """
  def sort(
        base_query,
        schema,
        sort_query,
        sortable_fields,
        mapping \\ DefaultMapping
      )
      when is_list(sortable_fields) do
    case sort_query do
      %{"field" => field, "order" => order} ->
        sorted_query(base_query, field, order, sortable_fields, schema, mapping)

      _ ->
        base_query
    end
  end

  defp sorted_query(base_query, field, order, sortable_fields, schema, mapping) do
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
