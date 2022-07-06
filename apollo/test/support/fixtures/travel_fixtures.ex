defmodule Apollo.TravelFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Apollo.Travel` context.
  """

  @doc """
  Generate a location.
  """
  def location_fixture(attrs \\ %{}) do
    {:ok, location} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Apollo.Travel.create_location()

    location
  end
end
