defmodule Apollo.Repo.Migrations.SeedLocations do
  use Ecto.Migration

  def change do
    Apollo.Travel.create_location(%{name: "Mars"})
    Apollo.Travel.create_location(%{name: "Venus"})
    Apollo.Travel.create_location(%{name: "Saturn"})
  end
end
