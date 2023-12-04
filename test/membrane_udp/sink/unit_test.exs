defmodule Membrane.UDP.SinkUnitTest do
  use ExUnit.Case
  use Mockery

  alias Membrane.Buffer
  alias Membrane.UDP.{Endpoint, Sink, Socket, SocketFactory}

  describe "Sink element" do
    test "handle_buffer/4 calls send and demands more data" do
      mock(Socket, [send: 3], :ok)
      payload_data = "binary data"
      local_socket = SocketFactory.local_socket(1234)
      dst_socket = SocketFactory.local_socket(4321)

      state = %{
        local_socket: local_socket,
        dst_socket: dst_socket
      }

      assert Sink.handle_buffer(:input, %Buffer{payload: payload_data}, nil, state) ==
               {[demand: :input], state}

      assert_called(Socket, :send, [^dst_socket, ^local_socket, ^payload_data])
    end

    test "demands data when starting to play" do
      assert {commands, nil} = Sink.handle_playing(nil, nil)

      assert Keyword.fetch(commands, :demand) == {:ok, :input}
    end
  end

  describe "Endpoint element" do
    test "handle_write/4 calls send and demands more data" do
      mock(Socket, [send: 3], :ok)
      payload_data = "binary data"
      local_socket = SocketFactory.local_socket(1234)
      dst_socket = SocketFactory.local_socket(4321)

      state = %{
        local_socket: local_socket,
        dst_socket: dst_socket
      }

      assert Endpoint.handle_write(:input, %Buffer{payload: payload_data}, nil, state) ==
               {[demand: :input], state}

      assert_called(Socket, :send, [^dst_socket, ^local_socket, ^payload_data])
    end

    test "demands data when starting to play" do
      assert {commands, nil} = Endpoint.handle_playing(nil, nil)

      assert Keyword.fetch(commands, :demand) == {:ok, :input}
    end
  end
end
