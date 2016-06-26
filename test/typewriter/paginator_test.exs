defmodule Typewriter.PaginatorTest do
  use ExUnit.Case
  doctest Typewriter.Paginator

  alias Typewriter.Paginator

  setup do
    :ok
  end

  test "should paginate lists correctly" do
    assert Paginator.paginate((1..20), 6) == [[1,2,3,4,5,6], [7,8,9,10,11,12], [13,14,15,16,17,18], [19, 20]]
  end

  test "should return an empty list when paginating empty lists" do
    assert Paginator.paginate([], 5) == []
  end
end
