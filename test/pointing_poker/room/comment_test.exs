defmodule PointingPoker.Room.CommentTest do
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

      :ok = flush(1 + 2 + 3)

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

    test "invalid user does not crash room with comment", %{
      pid: pid,
      vid1: vid1,
      vid2: vid2,
      oid: oid
    } do
      :ok = Room.comment(pid, "somethign", "abc")
      :ok = Room.trigger_update(pid)

      assert_receive %Update{me: %Member{id: ^vid1}, comment: ""}
      assert_receive %Update{me: %Member{id: ^vid2}, comment: ""}
      assert_receive %Update{me: %Member{id: ^oid}, comment: ""}
    end

    test "voter can't comment", %{pid: pid, vid1: vid1, vid2: vid2, oid: oid} do
      :ok = Room.comment(pid, vid1, "abc")
      :ok = Room.trigger_update(pid)

      assert_receive %Update{me: %Member{id: ^vid1}, comment: ""}
      assert_receive %Update{me: %Member{id: ^vid2}, comment: ""}
      assert_receive %Update{me: %Member{id: ^oid}, comment: ""}
    end

    test "observer can comment", %{pid: pid, vid1: vid1, vid2: vid2, oid: oid} do
      :ok = Room.comment(pid, oid, "abc")

      assert_receive %Update{me: %Member{id: ^vid1}, comment: "abc"}
      assert_receive %Update{me: %Member{id: ^vid2}, comment: "abc"}
      assert_receive %Update{me: %Member{id: ^oid}, comment: "abc"}
    end
  end

  describe "in room with voter as manager_role" do
    setup do
      {:ok, room_id} = Room.new([1, 5, 80.1, 2.5, 3, 3, "10"], :voter)
      {:ok, room} = Room.find(room_id)

      voter1 = %Member{} = Room.join(room.pid, "Ma name 1", :voter)
      voter2 = %Member{} = Room.join(room.pid, "Ma name 2", :voter)
      observer = %Member{} = Room.join(room.pid, "Ma name obs", :observer)

      :ok = flush(1 + 2 + 3)

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

    test "invalid user does not crash room with clear_votes", %{
      pid: pid,
      vid1: vid1,
      vid2: vid2,
      oid: oid
    } do
      :ok = Room.clear_votes(pid, "somethign")
      :ok = Room.trigger_update(pid)

      assert_receive %Update{me: %Member{id: ^vid1}, comment: ""}
      assert_receive %Update{me: %Member{id: ^vid2}, comment: ""}
      assert_receive %Update{me: %Member{id: ^oid}, comment: ""}
    end

    test "voter can comment", %{pid: pid, vid1: vid1, vid2: vid2, oid: oid} do
      :ok = Room.comment(pid, vid1, "abc")

      assert_receive %Update{me: %Member{id: ^vid1}, comment: "abc"}
      assert_receive %Update{me: %Member{id: ^vid2}, comment: "abc"}
      assert_receive %Update{me: %Member{id: ^oid}, comment: "abc"}
    end

    test "observer can comment", %{pid: pid, vid1: vid1, vid2: vid2, oid: oid} do
      :ok = Room.comment(pid, oid, "abc")

      assert_receive %Update{me: %Member{id: ^vid1}, comment: "abc"}
      assert_receive %Update{me: %Member{id: ^vid2}, comment: "abc"}
      assert_receive %Update{me: %Member{id: ^oid}, comment: "abc"}
    end
  end
end
