defmodule PointingPoker.Room.LifetimeTest do
  use ExUnit.Case

  alias PointingPoker.Room
  alias PointingPoker.Error

  test "room creation with valid data" do
    assert {:ok, room_id} = Room.new([1, 5, 80.1, 2.5, 3, 3, "10"], :voter)
    assert String.length(room_id) > 5

    assert {:ok, room = %Room.Config{}} = Room.find(room_id)

    assert room.id == room_id
    assert room.enabled_values == [1, 2.5, 3, 5, 80.1]
    assert room.manager_type == :voter
    assert is_pid(room.pid)

    assert Process.alive?(room.pid)
  end

  test "room creation with valid manager types" do
    assert {:ok, _room_id} = Room.new([1, 5, 80.1, 2.5, 3, 3, "10"], :voter)
    assert {:ok, _room_id} = Room.new([1, 5, 80.1, 2.5, 3, 3, "10"], :observer)
  end

  test "room creation with invalid manager types" do
    assert {:error,
            %Error{
              category: :invalid_argument,
              details: :manager_type
            }} = Room.new([1, 5, 80.1, 2.5, 3, 3, "10"], :something_else)

    assert {:error,
            %Error{
              category: :invalid_argument,
              details: :manager_type
            }} = Room.new([1, 5, 80.1, 2.5, 3, 3, "10"], "voter")
  end
end
