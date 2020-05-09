defmodule PointingPokerWeb.LayoutView do
  use PointingPokerWeb, :view

  def theme_name(assigns) do
    Map.get(assigns, :theme, "light")
  end
end
