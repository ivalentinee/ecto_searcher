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

  @type sort_params() :: %{String.t() => String.t()}
  @type sortable_fields() :: [atom()]

  require Ecto.Query
  alias Ecto.Query
  alias EctoSearcher.Mapping.Default, as: DefaultMapping
  alias EctoSearcher.Utils.Field

  @doc """
  Shortcut for `sort/5`
  """
  @spec sort(Ecto.Queryable.t(), Ecto.Schema.t(), sort_params()) :: Ecto.Queryable.t()
  def sort(base_query, schema, sort_params) do
    sortable_fields = Field.searchable_fields(schema, DefaultMapping)
    mapping = DefaultMapping

    sort(base_query, schema, sort_params, mapping, sortable_fields)
  end

  @doc """
  Builds sort query

  `sort_params` should be a map with "field" and "order" like this:
  ```elixir
    %{
      "field" => "name",
      "order" => "asc"
    }
  ```

  `mapping` should implement `EctoSearcher.Mapping` behavior. `EctoSearcher.Mapping.Default` provides some basics.

  `sortable_fields` is a list with fields (atoms) permitted for sorting. If not provided (or `nil`) all fields are allowed for sorting:
  ```elixir
  [:name, :description]
  ```
  """
  @spec sort(
          Ecto.Queryable.t(),
          Ecto.Schema.t(),
          sort_params(),
          module(),
          sortable_fields() | nil
        ) :: Ecto.Queryable.t()
  def sort(
        base_query,
        schema,
        sort_params,
        mapping,
        sortable_fields \\ nil
      )
      when is_list(sortable_fields) or is_nil(sortable_fields) do
    sortable_fields = sortable_fields || Field.searchable_fields(schema, mapping)

    case sort_params do
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
