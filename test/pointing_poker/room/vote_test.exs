defmodule PointingPoker.Room.VoteTest do
  use ExUnit.Case

  alias PointingPoker.Room
  alias PointingPoker.Room.{Update, Member}

  import PointingPoker.TestUtils.Room

  setup do
    {:ok, room_id} = Room.new([1, 5, 80.1, 2.5, 3, 3, "10"], :voter)
    {:ok, room} = Room.find(room_id)

    voter1 = %Member{} = Room.join(room.pid, "Ma name 1", :voter)
    voter2 = %Member{} = Room.join(room.pid, "Ma name 2", :voter)
    observer = %Member{} = Room.join(room.pid, "Ma name obs", :observer)

    :ok = flush(6)

    %{pid: room.pid, voter1: voter1, voter2: voter2, observer: observer}
  end

  test "voting with invalid user id does not crash the room", %{pid: pid, voter1: voter1} do
    assert :ok = Room.vote(pid, "something", 5)

    assert :ok = Room.vote(pid, voter1.id, 5)
    update = assert_receive %Update{}

    assert %Member{vote: 5} = get_member(update, voter1.id)
  end

  test "voters can vote with correct vote", %{pid: pid, voter1: voter1, voter2: voter2} do
    assert :ok = Room.vote(pid, voter1.id, 5)
    update = assert_receive %Update{}

    assert %Member{vote: 5} = get_member(update, voter1.id)

    assert %Member{vote: nil} = get_member(update, voter2.id)

    :ok = flush(2)

    assert :ok = Room.vote(pid, voter2.id, 3)
    update = assert_receive %Update{}

    assert %Member{vote: 5} = get_member(update, voter1.id)

    assert %Member{vote: 3} = get_member(update, voter2.id)

    :ok = flush(2)
  end

  test "observers can't vote", %{pid: pid, observer: observer, voter1: voter1} do
    assert :ok = Room.vote(pid, observer.id, 5)

    assert :ok = Room.vote(pid, voter1.id, 3)
    update = assert_receive %Update{}

    assert %Member{vote: 3} = get_member(update, voter1.id)

    assert %Member{vote: nil} = get_member(update, observer.id)
  end

  test "voters can't vote with incorrect vote", %{pid: pid, voter1: voter1, voter2: voter2} do
    assert :ok = Room.vote(pid, voter1.id, 10)

    assert :ok = Room.vote(pid, voter2.id, 3)
    update = assert_receive %Update{}

    assert %Member{vote: nil} = get_member(update, voter1.id)

    assert %Member{vote: 3} = get_member(update, voter2.id)
  end
end
