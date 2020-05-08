defmodule PointingPoker.Room.JoinTest do
  use ExUnit.Case

  alias PointingPoker.Room
  alias PointingPoker.Room.{Update, Member}

  import PointingPoker.TestUtils.Room

  setup do
    {:ok, room_id} = Room.new([1, 5, 80.1, 2.5, 3, 3, "10"], :voter)
    {:ok, room} = Room.find(room_id)
    %{pid: room.pid}
  end

  test "can't join the room with invalid role", %{pid: pid} do
    assert :error = Room.join(pid, "my name voter", :whatever)
  end

  test "anyone can join the room with valid role", %{pid: pid} do
    my_pid = self()

    voter =
      assert %Member{
               name: "my name voter",
               role: :voter,
               vote: nil,
               pid: ^my_pid
             } = Room.join(pid, "my name voter", :voter)

    update = assert_receive %Update{}
    assert length(update.members) == 1

    assert %Member{
             name: "my name voter",
             role: :voter,
             vote: nil,
             pid: ^my_pid
           } = get_member(update, voter.id)

    observer =
      assert %Member{
               name: "my name observer",
               role: :observer,
               vote: nil,
               pid: ^my_pid
             } = Room.join(pid, "my name observer", :observer)

    update = assert_receive %Update{}
    assert length(update.members) == 2

    assert %Member{
             name: "my name observer",
             role: :observer,
             vote: nil,
             pid: ^my_pid
           } = get_member(update, observer.id)
  end
end
