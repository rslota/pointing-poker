defmodule PointingPoker.Room.ShowVotesTest do
  use ExUnit.Case

  alias PointingPoker.Room
  alias PointingPoker.Room.{Update, Member}

  import PointingPoker.TestUtils.Room

  describe "in room with observer as manager_role" do
    setup do
      {:ok, room_id} = Room.new([1, 5, 80.1, 2.5, 3, 3, "10"], :observer)
      {:ok, room} = Room.find(room_id)

      voter1 = %Member{} = Room.join(room.pid, "Ma name 1", :voter)
      voter2 = %Member{} = Room.join(room.pid, "Ma name 2", :voter)
      observer = %Member{} = Room.join(room.pid, "Ma name obs", :observer)

      :ok = flush(6)

      %{
        pid: room.pid,
        voter1: voter1,
        voter2: voter2,
        observer: observer,
        vid1: voter1.id,
        vid2: voter2.id,
        oid: observer.id
      }
    end

    test "invalid user does not crash room with show_votes on/off", %{
      pid: pid,
      vid1: vid1,
      vid2: vid2,
      oid: oid
    } do
      :ok = Room.show_votes(pid, "somethign", true)
      :ok = Room.trigger_update(pid)

      assert_receive %Update{show_votes?: false, me: %Member{id: ^vid1}}
      assert_receive %Update{show_votes?: false, me: %Member{id: ^vid2}}
      assert_receive %Update{show_votes?: false, me: %Member{id: ^oid}}

      :ok = Room.show_votes(pid, oid, true)
      assert_receive %Update{show_votes?: true, me: %Member{id: ^vid1}}
      assert_receive %Update{show_votes?: true, me: %Member{id: ^vid2}}
      assert_receive %Update{show_votes?: true, me: %Member{id: ^oid}}
    end

    test "voter can't switch show_votes on/off", %{pid: pid, vid1: vid1, vid2: vid2, oid: oid} do
      :ok = Room.show_votes(pid, vid1, true)
      :ok = Room.trigger_update(pid)

      assert_receive %Update{show_votes?: false, me: %Member{id: ^vid1}}
      assert_receive %Update{show_votes?: false, me: %Member{id: ^vid2}}
      assert_receive %Update{show_votes?: false, me: %Member{id: ^oid}}

      :ok = Room.show_votes(pid, oid, true)
      assert_receive %Update{show_votes?: true, me: %Member{id: ^vid1}}
      assert_receive %Update{show_votes?: true, me: %Member{id: ^vid2}}
      assert_receive %Update{show_votes?: true, me: %Member{id: ^oid}}
    end

    test "observer can switch show_votes on/off", %{pid: pid, vid1: vid1, vid2: vid2, oid: oid} do
      :ok = Room.show_votes(pid, oid, true)
      assert_receive %Update{show_votes?: true, me: %Member{id: ^vid1}}
      assert_receive %Update{show_votes?: true, me: %Member{id: ^vid2}}
      assert_receive %Update{show_votes?: true, me: %Member{id: ^oid}}

      :ok = Room.show_votes(pid, oid, false)
      assert_receive %Update{show_votes?: false, me: %Member{id: ^vid1}}
      assert_receive %Update{show_votes?: false, me: %Member{id: ^vid2}}
      assert_receive %Update{show_votes?: false, me: %Member{id: ^oid}}
    end
  end

  describe "in room with voter as manager_role" do
    setup do
      {:ok, room_id} = Room.new([1, 5, 80.1, 2.5, 3, 3, "10"], :voter)
      {:ok, room} = Room.find(room_id)

      voter1 = %Member{} = Room.join(room.pid, "Ma name 1", :voter)
      voter2 = %Member{} = Room.join(room.pid, "Ma name 2", :voter)
      observer = %Member{} = Room.join(room.pid, "Ma name obs", :observer)

      :ok = flush(6)

      %{
        pid: room.pid,
        voter1: voter1,
        voter2: voter2,
        observer: observer,
        vid1: voter1.id,
        vid2: voter2.id,
        oid: observer.id
      }
    end

    test "invalid user does not crash room with show_votes on/off", %{
      pid: pid,
      vid1: vid1,
      vid2: vid2,
      oid: oid
    } do
      :ok = Room.show_votes(pid, "somethign", true)
      :ok = Room.trigger_update(pid)

      assert_receive %Update{show_votes?: false, me: %Member{id: ^vid1}}
      assert_receive %Update{show_votes?: false, me: %Member{id: ^vid2}}
      assert_receive %Update{show_votes?: false, me: %Member{id: ^oid}}

      :ok = Room.show_votes(pid, vid1, true)
      assert_receive %Update{show_votes?: true, me: %Member{id: ^vid1}}
      assert_receive %Update{show_votes?: true, me: %Member{id: ^vid2}}
      assert_receive %Update{show_votes?: true, me: %Member{id: ^oid}}
    end

    test "voter can switch show_votes on/off", %{pid: pid, vid1: vid1, vid2: vid2, oid: oid} do
      :ok = Room.show_votes(pid, vid1, true)
      assert_receive %Update{show_votes?: true, me: %Member{id: ^vid1}}
      assert_receive %Update{show_votes?: true, me: %Member{id: ^vid2}}
      assert_receive %Update{show_votes?: true, me: %Member{id: ^oid}}

      :ok = Room.show_votes(pid, vid2, false)
      assert_receive %Update{show_votes?: false, me: %Member{id: ^vid1}}
      assert_receive %Update{show_votes?: false, me: %Member{id: ^vid2}}
      assert_receive %Update{show_votes?: false, me: %Member{id: ^oid}}
    end

    test "observer can switch show_votes on/off", %{pid: pid, vid1: vid1, vid2: vid2, oid: oid} do
      :ok = Room.show_votes(pid, oid, true)
      assert_receive %Update{show_votes?: true, me: %Member{id: ^vid1}}
      assert_receive %Update{show_votes?: true, me: %Member{id: ^vid2}}
      assert_receive %Update{show_votes?: true, me: %Member{id: ^oid}}

      :ok = Room.show_votes(pid, oid, false)
      assert_receive %Update{show_votes?: false, me: %Member{id: ^vid1}}
      assert_receive %Update{show_votes?: false, me: %Member{id: ^vid2}}
      assert_receive %Update{show_votes?: false, me: %Member{id: ^oid}}
    end
  end
end
