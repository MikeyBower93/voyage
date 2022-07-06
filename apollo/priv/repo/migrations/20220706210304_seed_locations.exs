defmodule Apollo.Repo.Migrations.SeedLocations do
  use Ecto.Migration

  def change do
    Travel.create_location(%{name: "Mars"})
    Travel.create_location(%{name: "Venus"})
    Travel.create_location(%{name: "Saturn"})
  end
end
