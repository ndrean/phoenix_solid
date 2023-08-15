defmodule PhxSolidWeb.OneTapControllerTest do
  @moduledoc false

  use PhxSolidWeb.ConnCase
  use ExUnit.Case

  @endpoint PhxSolidWeb.OneTapController
  @create_attrs %{
    body: %{"code" => "code", "g_crsf" => "g_csrf"},
    cookies: %{"g_csrf_token" => "cookie"}
  }
  @invalid_attrs %{body: %{"code" => "code", "g_csrf" => "hack"}}

  describe("plug csrf for Google One Tap") do
    test "returns true or false", %{conn: conn} do
      conn = get(conn, ~p"/users/log_in")
      assert PhxSolidWeb.OneTapController.check_csrf(conn, {}) == true
    end
  end
end
