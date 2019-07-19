defmodule CoophubWeb.OrgView do
  use CoophubWeb, :view

  def render("show.json", %{org: org}) do
    %{org: org}
  end
end
