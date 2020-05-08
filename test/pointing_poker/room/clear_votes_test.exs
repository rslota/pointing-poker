defmodule PointingPoker.Room.ClearVotesTest do
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

      :ok = Room.vote(room.pid, voter1.id, 5)
      :ok = Room.vote(room.pid, voter2.id, 3)

      :ok = Room.show_votes(room.pid, observer.id, true)
      :ok = Room.comment(room.pid, observer.id, "abc")

      :ok = flush(4 * 3)

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

      assert_receive %Update{me: %Member{id: ^vid1}, show_votes?: true, comment: "abc"} = update
      assert %Member{vote: 5} = get_member(update, vid1)
      assert %Member{vote: 3} = get_member(update, vid2)

      assert_receive %Update{me: %Member{id: ^vid2}, show_votes?: true, comment: "abc"} = update
      assert %Member{vote: 5} = get_member(update, vid1)
      assert %Member{vote: 3} = get_member(update, vid2)

      assert_receive %Update{me: %Member{id: ^oid}, show_votes?: true, comment: "abc"} = update
      assert %Member{vote: 5} = get_member(update, vid1)
      assert %Member{vote: 3} = get_member(update, vid2)
    end

    test "voter can't clear_votes", %{pid: pid, vid1: vid1, vid2: vid2, oid: oid} do
      :ok = Room.clear_votes(pid, vid1)
      :ok = Room.trigger_update(pid)

      assert_receive %Update{me: %Member{id: ^vid1}, show_votes?: true, comment: "abc"} = update
      assert %Member{vote: 5} = get_member(update, vid1)
      assert %Member{vote: 3} = get_member(update, vid2)

      assert_receive %Update{me: %Member{id: ^vid2}, show_votes?: true, comment: "abc"} = update
      assert %Member{vote: 5} = get_member(update, vid1)
      assert %Member{vote: 3} = get_member(update, vid2)

      assert_receive %Update{me: %Member{id: ^oid}, show_votes?: true, comment: "abc"} = update
      assert %Member{vote: 5} = get_member(update, vid1)
      assert %Member{vote: 3} = get_member(update, vid2)
    end

    test "observer can clear_votes", %{pid: pid, vid1: vid1, vid2: vid2, oid: oid} do
      :ok = Room.clear_votes(pid, oid)

      assert_receive %Update{me: %Member{id: ^vid1}, show_votes?: true, comment: ""} = update
      assert %Member{vote: nil} = get_member(update, vid1)
      assert %Member{vote: nil} = get_member(update, vid2)

      assert_receive %Update{me: %Member{id: ^vid2}, show_votes?: true, comment: ""} = update
      assert %Member{vote: nil} = get_member(update, vid1)
      assert %Member{vote: nil} = get_member(update, vid2)

      assert_receive %Update{me: %Member{id: ^oid}, show_votes?: true, comment: ""} = update
      assert %Member{vote: nil} = get_member(update, vid1)
      assert %Member{vote: nil} = get_member(update, vid2)
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

      :ok = Room.vote(room.pid, voter1.id, 5)
      :ok = Room.vote(room.pid, voter2.id, 3)

      :ok = Room.show_votes(room.pid, observer.id, true)
      :ok = Room.comment(room.pid, observer.id, "abc")

      :ok = flush(4 * 3)

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

      assert_receive %Update{me: %Member{id: ^vid1}, show_votes?: true, comment: "abc"} = update
      assert %Member{vote: 5} = get_member(update, vid1)
      assert %Member{vote: 3} = get_member(update, vid2)

      assert_receive %Update{me: %Member{id: ^vid2}, show_votes?: true, comment: "abc"} = update
      assert %Member{vote: 5} = get_member(update, vid1)
      assert %Member{vote: 3} = get_member(update, vid2)

      assert_receive %Update{me: %Member{id: ^oid}, show_votes?: true, comment: "abc"} = update
      assert %Member{vote: 5} = get_member(update, vid1)
      assert %Member{vote: 3} = get_member(update, vid2)
    end

    test "voter can clear_votes", %{pid: pid, vid1: vid1, vid2: vid2, oid: oid} do
      :ok = Room.clear_votes(pid, vid1)

      assert_receive %Update{me: %Member{id: ^vid1}, show_votes?: true, comment: ""} = update
      assert %Member{vote: nil} = get_member(update, vid1)
      assert %Member{vote: nil} = get_member(update, vid2)

      assert_receive %Update{me: %Member{id: ^vid2}, show_votes?: true, comment: ""} = update
      assert %Member{vote: nil} = get_member(update, vid1)
      assert %Member{vote: nil} = get_member(update, vid2)

      assert_receive %Update{me: %Member{id: ^oid}, show_votes?: true, comment: ""} = update
      assert %Member{vote: nil} = get_member(update, vid1)
      assert %Member{vote: nil} = get_member(update, vid2)
    end

    test "observer can clear_votes", %{pid: pid, vid1: vid1, vid2: vid2, oid: oid} do
      :ok = Room.clear_votes(pid, oid)

      assert_receive %Update{me: %Member{id: ^vid1}, show_votes?: true, comment: ""} = update
      assert %Member{vote: nil} = get_member(update, vid1)
      assert %Member{vote: nil} = get_member(update, vid2)

      assert_receive %Update{me: %Member{id: ^vid2}, show_votes?: true, comment: ""} = update
      assert %Member{vote: nil} = get_member(update, vid1)
      assert %Member{vote: nil} = get_member(update, vid2)

      assert_receive %Update{me: %Member{id: ^oid}, show_votes?: true, comment: ""} = update
      assert %Member{vote: nil} = get_member(update, vid1)
      assert %Member{vote: nil} = get_member(update, vid2)
    end
  end
end
