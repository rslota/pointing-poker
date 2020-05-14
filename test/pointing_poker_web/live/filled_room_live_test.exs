defmodule PointingPokerWeb.FilledRoomLiveTest do
  use PointingPokerWeb.ConnCase
  use AssertEventually
  alias PointingPoker.Room

  import Phoenix.LiveViewTest

  describe "in room with voter as manager" do
    setup do
      {:ok, room_id} = Room.new([1, 5, 80.1, 2.5, 3, 3, 10], :voter)
      {:ok, room} = Room.find(room_id)

      join_all(room)
    end

    test "users can see someone leaving", %{voters: voters, observers: observers} do
      for user <- Map.values(voters) ++ Map.values(observers) do
        for i <- 1..9 do
          assert user |> element("tr[name='Voter #{i}']") |> has_element?()
        end
      end

      voter_dc = voters[5]
      Process.flag(:trap_exit, true)
      Process.exit(voter_dc.pid, :crash)

      for user <- Map.values(voters) ++ Map.values(observers) do
        if user.pid != voter_dc.pid do
          for i <- 1..4 do
            assert user |> element("tr[name='Voter #{i}']") |> has_element?()
          end

          eventually(refute user |> element("tr[name='Voter 5']") |> has_element?())

          for i <- 6..9 do
            assert user |> element("tr[name='Voter #{i}']") |> has_element?()
          end
        end
      end
    end

    test "voters cant vote with invalid vote", %{voters: voters, observers: observers} do
      render_click(voters[1], "vote", %{"value" => "58"})

      for user <- Map.values(voters) ++ Map.values(observers) do
        eventually(
          refute user |> element("tr[name='Voter 1'] td.member_ready") |> render() =~ "✓"
        )
      end
    end

    test "observers can comment", %{voters: voters, observers: observers} do
      render_change(observers[1], "comment", %{"comment" => "abc def"})

      for user <- Map.values(voters) ++ Map.values(observers) do
        eventually(
          assert element(user, "form[phx-change=comment] textarea[name=comment]") |> render() =~
                   "abc def"
        )
      end

      render_change(observers[2], "comment", %{"comment" => "def abc"})

      for user <- Map.values(voters) ++ Map.values(observers) do
        eventually(
          assert element(user, "form[phx-change=comment] textarea[name=comment]") |> render() =~
                   "def abc"
        )
      end
    end

    test "voters can comment", %{voters: voters, observers: observers} do
      render_change(observers[1], "comment", %{"comment" => "abc def"})

      for user <- Map.values(voters) ++ Map.values(observers) do
        eventually(
          assert element(user, "form[phx-change=comment] textarea[name=comment]") |> render() =~
                   "abc def"
        )
      end

      render_change(voters[1], "comment", %{"comment" => "def abc"})

      for user <- Map.values(voters) ++ Map.values(observers) do
        eventually(
          assert element(user, "form[phx-change=comment] textarea[name=comment]") |> render() =~
                   "def abc"
        )
      end
    end

    test "observers can show and clear votes", %{voters: voters, observers: observers} do
      render_click(voters[1], "vote", %{"value" => "5"})
      render_click(voters[2], "vote", %{"value" => "3"})
      render_click(voters[3], "vote", %{"value" => "80.1"})
      render_click(voters[4], "vote", %{"value" => "?"})

      render_click(observers[1], "show", %{})

      for user <- Map.values(voters) ++ Map.values(observers) do
        eventually(
          assert user |> element("tr[name='Voter 1'] td.member_ready") |> render() =~ "✓"
        )

        eventually(assert user |> element("tr[name='Voter 1'] td.member_vote") |> render() =~ "5")

        eventually(
          assert user |> element("tr[name='Voter 2'] td.member_ready") |> render() =~ "✓"
        )

        eventually(assert user |> element("tr[name='Voter 2'] td.member_vote") |> render() =~ "3")

        eventually(
          assert user |> element("tr[name='Voter 3'] td.member_ready") |> render() =~ "✓"
        )

        eventually(
          assert user |> element("tr[name='Voter 3'] td.member_vote") |> render() =~ "80.1"
        )

        eventually(
          assert user |> element("tr[name='Voter 4'] td.member_ready") |> render() =~ "✓"
        )

        eventually(assert user |> element("tr[name='Voter 4'] td.member_vote") |> render() =~ "?")

        for i <- 5..9 do
          eventually(
            refute user |> element("tr[name='Voter #{i}'] td.member_ready") |> render() =~ "✓"
          )

          eventually(
            refute user |> element("tr[name='Voter #{i}'] td.member_vote") |> render() =~ "■"
          )
        end
      end

      render_click(observers[2], "clear", %{})

      for user <- Map.values(voters) ++ Map.values(observers) do
        for i <- 1..9 do
          eventually(
            refute user |> element("tr[name='Voter #{i}'] td.member_ready") |> render() =~ "✓"
          )

          if voters[i] != user do
            eventually(
              assert user |> element("tr[name='Voter #{i}'] td.member_vote") |> render() =~ "■"
            )
          else
            eventually(
              assert user |> element("tr[name='Voter #{i}'] td.member_vote") |> render() =~
                       "<b></b>"
            )
          end
        end
      end
    end

    test "voters can show and clear votes", %{voters: voters, observers: observers} do
      render_click(voters[1], "vote", %{"value" => "5"})
      render_click(voters[2], "vote", %{"value" => "3"})
      render_click(voters[3], "vote", %{"value" => "80.1"})
      render_click(voters[4], "vote", %{"value" => "?"})

      render_click(voters[5], "show", %{})

      for user <- Map.values(voters) ++ Map.values(observers) do
        eventually(
          assert user |> element("tr[name='Voter 1'] td.member_ready") |> render() =~ "✓"
        )

        eventually(assert user |> element("tr[name='Voter 1'] td.member_vote") |> render() =~ "5")

        eventually(
          assert user |> element("tr[name='Voter 2'] td.member_ready") |> render() =~ "✓"
        )

        eventually(assert user |> element("tr[name='Voter 2'] td.member_vote") |> render() =~ "3")

        eventually(
          assert user |> element("tr[name='Voter 3'] td.member_ready") |> render() =~ "✓"
        )

        eventually(
          assert user |> element("tr[name='Voter 3'] td.member_vote") |> render() =~ "80.1"
        )

        eventually(
          assert user |> element("tr[name='Voter 4'] td.member_ready") |> render() =~ "✓"
        )

        eventually(assert user |> element("tr[name='Voter 4'] td.member_vote") |> render() =~ "?")

        for i <- 5..9 do
          eventually(
            refute user |> element("tr[name='Voter #{i}'] td.member_ready") |> render() =~ "✓"
          )

          eventually(
            refute user |> element("tr[name='Voter #{i}'] td.member_vote") |> render() =~ "■"
          )
        end
      end

      render_click(voters[6], "clear", %{})

      for user <- Map.values(voters) ++ Map.values(observers) do
        for i <- 1..9 do
          eventually(
            refute user |> element("tr[name='Voter #{i}'] td.member_ready") |> render() =~ "✓"
          )

          if voters[i] != user do
            eventually(
              assert user |> element("tr[name='Voter #{i}'] td.member_vote") |> render() =~ "■"
            )
          else
            eventually(
              assert user |> element("tr[name='Voter #{i}'] td.member_vote") |> render() =~
                       "<b></b>"
            )
          end
        end
      end
    end

    test "voters can see vote average if they didn't vote the same", %{
      voters: voters,
      observers: observers
    } do
      render_click(voters[1], "vote", %{"value" => "3"})
      render_click(voters[4], "vote", %{"value" => "5"})
      render_click(voters[8], "vote", %{"value" => "80.1"})
      render_click(voters[2], "vote", %{"value" => "?"})

      render_click(observers[1], "show", %{})

      for user <- Map.values(voters) ++ Map.values(observers) do
        eventually(refute user |> element("div.vote-distrib") |> render() =~ "Consensus")
        eventually(assert user |> element("div.vote-avarage") |> render() =~ "29.37")
      end

      render_click(observers[2], "clear", %{})

      for user <- Map.values(voters) ++ Map.values(observers) do
        eventually(refute user |> element("div.vote-distrib") |> has_element?())
        eventually(refute user |> element("div.stats div.vote-avarage") |> has_element?())
      end
    end

    test "voters can see consensus if they voted the same", %{
      voters: voters,
      observers: observers
    } do
      render_click(voters[1], "vote", %{"value" => "5"})
      render_click(voters[4], "vote", %{"value" => "5"})
      render_click(voters[8], "vote", %{"value" => "5"})
      render_click(voters[2], "vote", %{"value" => "?"})

      render_click(observers[1], "show", %{})

      for user <- Map.values(voters) ++ Map.values(observers) do
        eventually(assert user |> element("div.vote-distrib") |> render() =~ "Consensus")
        eventually(assert user |> element("div.vote-avarage") |> render() =~ "5")
      end

      render_click(observers[2], "clear", %{})

      for user <- Map.values(voters) ++ Map.values(observers) do
        eventually(refute user |> element("div.vote-distrib") |> has_element?())
        eventually(refute user |> element("div.stats div.vote-avarage") |> has_element?())
      end
    end

    test "voters can vote with valid vote", %{voters: voters, observers: observers} do
      render_click(voters[1], "vote", %{"value" => "5"})

      for user <- Map.values(voters) ++ Map.values(observers) do
        eventually(
          assert user |> element("tr[name='Voter 1'] td.member_ready") |> render() =~ "✓"
        )

        eventually(
          refute user |> element("tr[name='Voter 2'] td.member_ready") |> render() =~ "✓"
        )

        eventually(
          refute user |> element("tr[name='Voter 3'] td.member_ready") |> render() =~ "✓"
        )

        if voters[1] == user do
          eventually(
            assert user |> element("tr[name='Voter 1'] td.member_vote") |> render() =~ "5"
          )
        else
          eventually(
            assert user |> element("tr[name='Voter 1'] td.member_vote") |> render() =~ "■"
          )
        end

        if voters[2] != user do
          eventually(
            assert user |> element("tr[name='Voter 2'] td.member_vote") |> render() =~ "■"
          )
        end

        if voters[3] != user do
          eventually(
            assert user |> element("tr[name='Voter 3'] td.member_vote") |> render() =~ "■"
          )
        end
      end

      render_click(voters[2], "vote", %{"value" => "3"})

      for user <- Map.values(voters) ++ Map.values(observers) do
        eventually(
          assert user |> element("tr[name='Voter 1'] td.member_ready") |> render() =~ "✓"
        )

        eventually(
          assert user |> element("tr[name='Voter 2'] td.member_ready") |> render() =~ "✓"
        )

        eventually(
          refute user |> element("tr[name='Voter 3'] td.member_ready") |> render() =~ "✓"
        )

        if voters[2] == user do
          eventually(
            assert user |> element("tr[name='Voter 2'] td.member_vote") |> render() =~ "3"
          )
        else
          eventually(
            assert user |> element("tr[name='Voter 2'] td.member_vote") |> render() =~ "■"
          )
        end

        if voters[1] != user do
          eventually(
            assert user |> element("tr[name='Voter 1'] td.member_vote") |> render() =~ "■"
          )
        end

        if voters[3] != user do
          eventually(
            assert user |> element("tr[name='Voter 3'] td.member_vote") |> render() =~ "■"
          )
        end
      end

      render_click(voters[3], "vote", %{"value" => "80.1"})

      for user <- Map.values(voters) ++ Map.values(observers) do
        eventually(
          assert user |> element("tr[name='Voter 1'] td.member_ready") |> render() =~ "✓"
        )

        eventually(
          assert user |> element("tr[name='Voter 2'] td.member_ready") |> render() =~ "✓"
        )

        eventually(
          assert user |> element("tr[name='Voter 3'] td.member_ready") |> render() =~ "✓"
        )

        if voters[3] == user do
          eventually(
            assert user |> element("tr[name='Voter 3'] td.member_vote") |> render() =~ "80.1"
          )
        else
          eventually(
            assert user |> element("tr[name='Voter 3'] td.member_vote") |> render() =~ "■"
          )
        end

        if voters[2] != user do
          eventually(
            assert user |> element("tr[name='Voter 2'] td.member_vote") |> render() =~ "■"
          )
        end

        if voters[1] != user do
          eventually(
            assert user |> element("tr[name='Voter 1'] td.member_vote") |> render() =~ "■"
          )
        end
      end

      render_click(voters[4], "vote", %{"value" => "?"})

      for user <- Map.values(voters) ++ Map.values(observers) do
        eventually(
          assert user |> element("tr[name='Voter 1'] td.member_ready") |> render() =~ "✓"
        )

        eventually(
          assert user |> element("tr[name='Voter 2'] td.member_ready") |> render() =~ "✓"
        )

        eventually(
          assert user |> element("tr[name='Voter 3'] td.member_ready") |> render() =~ "✓"
        )

        eventually(
          assert user |> element("tr[name='Voter 4'] td.member_ready") |> render() =~ "✓"
        )

        if voters[4] == user do
          eventually(
            assert user |> element("tr[name='Voter 4'] td.member_vote") |> render() =~ "?"
          )
        else
          eventually(
            assert user |> element("tr[name='Voter 4'] td.member_vote") |> render() =~ "■"
          )
        end
      end
    end
  end

  describe "in room with observer as manager" do
    setup do
      {:ok, room_id} = Room.new([1, 5, 80.1, 2.5, 3, 3, 10], :observer)
      {:ok, room} = Room.find(room_id)

      join_all(room)
    end

    test "users can see someone leaving", %{voters: voters, observers: observers} do
      for user <- Map.values(voters) ++ Map.values(observers) do
        for i <- 1..9 do
          assert user |> element("tr[name='Voter #{i}']") |> has_element?()
        end
      end

      voter_dc = voters[5]
      Process.flag(:trap_exit, true)
      Process.exit(voter_dc.pid, :crash)

      for user <- Map.values(voters) ++ Map.values(observers) do
        if user.pid != voter_dc.pid do
          for i <- 1..4 do
            assert user |> element("tr[name='Voter #{i}']") |> has_element?()
          end

          eventually(refute user |> element("tr[name='Voter 5']") |> has_element?())

          for i <- 6..9 do
            assert user |> element("tr[name='Voter #{i}']") |> has_element?()
          end
        end
      end
    end

    test "observers can comment", %{voters: voters, observers: observers} do
      render_change(observers[1], "comment", %{"comment" => "abc def"})

      for user <- Map.values(voters) ++ Map.values(observers) do
        eventually(
          assert element(user, "form[phx-change=comment] textarea[name=comment]") |> render() =~
                   "abc def"
        )
      end

      render_change(observers[2], "comment", %{"comment" => "def abc"})

      for user <- Map.values(voters) ++ Map.values(observers) do
        eventually(
          assert element(user, "form[phx-change=comment] textarea[name=comment]") |> render() =~
                   "def abc"
        )
      end
    end

    test "voters can't comment", %{voters: voters, observers: observers} do
      render_change(observers[1], "comment", %{"comment" => "abc def"})

      for user <- Map.values(voters) ++ Map.values(observers) do
        eventually(
          assert element(user, "form[phx-change=comment] textarea[name=comment]") |> render() =~
                   "abc def"
        )
      end

      render_change(voters[1], "comment", %{"comment" => "def abc"})

      for user <- Map.values(voters) ++ Map.values(observers) do
        eventually(
          assert element(user, "form[phx-change=comment] textarea[name=comment]") |> render() =~
                   "abc def"
        )
      end
    end

    test "voters cant vote with invalid vote", %{voters: voters, observers: observers} do
      render_click(voters[1], "vote", %{"value" => "58"})

      for user <- Map.values(voters) ++ Map.values(observers) do
        eventually(
          refute user |> element("tr[name='Voter 1'] td.member_ready") |> render() =~ "✓"
        )
      end
    end

    test "observers can show and clear votes", %{voters: voters, observers: observers} do
      render_click(voters[1], "vote", %{"value" => "5"})
      render_click(voters[2], "vote", %{"value" => "3"})
      render_click(voters[3], "vote", %{"value" => "80.1"})

      render_click(observers[1], "show", %{})

      for user <- Map.values(voters) ++ Map.values(observers) do
        eventually(
          assert user |> element("tr[name='Voter 1'] td.member_ready") |> render() =~ "✓"
        )

        eventually(assert user |> element("tr[name='Voter 1'] td.member_vote") |> render() =~ "5")

        eventually(
          assert user |> element("tr[name='Voter 2'] td.member_ready") |> render() =~ "✓"
        )

        eventually(assert user |> element("tr[name='Voter 2'] td.member_vote") |> render() =~ "3")

        eventually(
          assert user |> element("tr[name='Voter 3'] td.member_ready") |> render() =~ "✓"
        )

        eventually(
          assert user |> element("tr[name='Voter 3'] td.member_vote") |> render() =~ "80.1"
        )

        for i <- 4..9 do
          eventually(
            refute user |> element("tr[name='Voter #{i}'] td.member_ready") |> render() =~ "✓"
          )

          eventually(
            refute user |> element("tr[name='Voter #{i}'] td.member_vote") |> render() =~ "■"
          )
        end
      end

      render_click(observers[2], "clear", %{})

      for user <- Map.values(voters) ++ Map.values(observers) do
        for i <- 1..9 do
          eventually(
            refute user |> element("tr[name='Voter #{i}'] td.member_ready") |> render() =~ "✓"
          )

          if voters[i] != user do
            eventually(
              assert user |> element("tr[name='Voter #{i}'] td.member_vote") |> render() =~ "■"
            )
          else
            eventually(
              assert user |> element("tr[name='Voter #{i}'] td.member_vote") |> render() =~
                       "<b></b>"
            )
          end
        end
      end
    end

    test "voters can't show or clear votes", %{voters: voters, observers: observers} do
      render_click(voters[1], "vote", %{"value" => "5"})
      render_click(voters[2], "vote", %{"value" => "3"})
      render_click(voters[3], "vote", %{"value" => "80.1"})

      render_click(voters[5], "show", %{})

      eventually(
        assert voters[1] |> element("tr[name='Voter 1'] td.member_vote") |> render() =~ "5"
      )

      eventually(
        assert voters[2] |> element("tr[name='Voter 2'] td.member_vote") |> render() =~ "3"
      )

      eventually(
        assert voters[3] |> element("tr[name='Voter 3'] td.member_vote") |> render() =~ "80.1"
      )

      for user <- Map.values(voters) ++ Map.values(observers) do
        for i <- 1..3 do
          eventually(
            assert user |> element("tr[name='Voter #{i}'] td.member_ready") |> render() =~ "✓"
          )

          if voters[i] != user do
            eventually(
              assert user |> element("tr[name='Voter #{i}'] td.member_vote") |> render() =~ "■"
            )
          end
        end
      end

      render_click(voters[6], "clear", %{})

      eventually(
        assert voters[1] |> element("tr[name='Voter 1'] td.member_vote") |> render() =~ "5"
      )

      eventually(
        assert voters[2] |> element("tr[name='Voter 2'] td.member_vote") |> render() =~ "3"
      )

      eventually(
        assert voters[3] |> element("tr[name='Voter 3'] td.member_vote") |> render() =~ "80.1"
      )

      for user <- Map.values(voters) ++ Map.values(observers) do
        for i <- 1..3 do
          eventually(
            assert user |> element("tr[name='Voter #{i}'] td.member_ready") |> render() =~ "✓"
          )

          if voters[i] != user do
            eventually(
              assert user |> element("tr[name='Voter #{i}'] td.member_vote") |> render() =~ "■"
            )
          end
        end
      end
    end

    test "voters can vote with valid vote", %{voters: voters, observers: observers} do
      render_click(voters[1], "vote", %{"value" => "5"})

      for user <- Map.values(voters) ++ Map.values(observers) do
        eventually(
          assert user |> element("tr[name='Voter 1'] td.member_ready") |> render() =~ "✓"
        )

        eventually(
          refute user |> element("tr[name='Voter 2'] td.member_ready") |> render() =~ "✓"
        )

        eventually(
          refute user |> element("tr[name='Voter 3'] td.member_ready") |> render() =~ "✓"
        )

        if voters[1] == user do
          eventually(
            assert user |> element("tr[name='Voter 1'] td.member_vote") |> render() =~ "5"
          )
        else
          eventually(
            assert user |> element("tr[name='Voter 1'] td.member_vote") |> render() =~ "■"
          )
        end

        if voters[2] != user do
          eventually(
            assert user |> element("tr[name='Voter 2'] td.member_vote") |> render() =~ "■"
          )
        end

        if voters[3] != user do
          eventually(
            assert user |> element("tr[name='Voter 3'] td.member_vote") |> render() =~ "■"
          )
        end
      end

      render_click(voters[2], "vote", %{"value" => "3"})

      for user <- Map.values(voters) ++ Map.values(observers) do
        eventually(
          assert user |> element("tr[name='Voter 1'] td.member_ready") |> render() =~ "✓"
        )

        eventually(
          assert user |> element("tr[name='Voter 2'] td.member_ready") |> render() =~ "✓"
        )

        eventually(
          refute user |> element("tr[name='Voter 3'] td.member_ready") |> render() =~ "✓"
        )

        if voters[2] == user do
          eventually(
            assert user |> element("tr[name='Voter 2'] td.member_vote") |> render() =~ "3"
          )
        else
          eventually(
            assert user |> element("tr[name='Voter 2'] td.member_vote") |> render() =~ "■"
          )
        end

        if voters[1] != user do
          eventually(
            assert user |> element("tr[name='Voter 1'] td.member_vote") |> render() =~ "■"
          )
        end

        if voters[3] != user do
          eventually(
            assert user |> element("tr[name='Voter 3'] td.member_vote") |> render() =~ "■"
          )
        end
      end

      render_click(voters[3], "vote", %{"value" => "80.1"})

      for user <- Map.values(voters) ++ Map.values(observers) do
        eventually(
          assert user |> element("tr[name='Voter 1'] td.member_ready") |> render() =~ "✓"
        )

        eventually(
          assert user |> element("tr[name='Voter 2'] td.member_ready") |> render() =~ "✓"
        )

        eventually(
          assert user |> element("tr[name='Voter 3'] td.member_ready") |> render() =~ "✓"
        )

        if voters[3] == user do
          eventually(
            assert user |> element("tr[name='Voter 3'] td.member_vote") |> render() =~ "80.1"
          )
        else
          eventually(
            assert user |> element("tr[name='Voter 3'] td.member_vote") |> render() =~ "■"
          )
        end

        if voters[2] != user do
          eventually(
            assert user |> element("tr[name='Voter 2'] td.member_vote") |> render() =~ "■"
          )
        end

        if voters[1] != user do
          eventually(
            assert user |> element("tr[name='Voter 1'] td.member_vote") |> render() =~ "■"
          )
        end
      end
    end
  end

  defp join_all(room) do
    voter_conns =
      1..9
      |> Enum.map(&{&1, Phoenix.ConnTest.build_conn()})
      |> Map.new()

    observers_conns =
      1..2
      |> Enum.map(&{&1, Phoenix.ConnTest.build_conn()})
      |> Map.new()

    voters =
      voter_conns
      |> Enum.map(fn {i, conn} ->
        {:ok, page_live, _disconnected_html} = live(conn, "/room/#{room.id}")

        render_submit(page_live, "join", %{
          "username" => "Voter #{i}",
          "role" => "voter"
        })

        {i, page_live}
      end)
      |> Map.new()

    observers =
      observers_conns
      |> Enum.map(fn {i, conn} ->
        {:ok, page_live, _disconnected_html} = live(conn, "/room/#{room.id}")

        render_submit(page_live, "join", %{
          "username" => "Bbserver #{i}",
          "role" => "observer"
        })

        {i, page_live}
      end)
      |> Map.new()

    %{voters: voters, observers: observers}
  end
end
