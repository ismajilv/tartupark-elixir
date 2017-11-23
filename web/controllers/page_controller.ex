defmodule Tartupark.PageController do
  use Tartupark.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
