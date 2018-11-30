defmodule Membrane.Element.UDP.SinkIntegrationTest do
  use ExUnit.Case, async: false

  import SocketSetup

  alias Membrane.Buffer
  alias Membrane.Element.UDP.{Sink, SocketFactory}

  @destination_port_no 5001
  @local_port_no 5000
  @local_address SocketFactory.local_address()

  def setup_state(_ctx) do
    dst_socket = SocketFactory.local_socket(@destination_port_no)
    local_socket = SocketFactory.local_socket(@local_port_no)

    %{state: %{dst_socket: dst_socket, local_socket: local_socket}}
  end

  setup [:setup_state, :setup_socket_from_state]

  @tag open_socket_from_state: [:dst_socket, :local_socket]
  test "Sends udp packet", %{state: state} do
    payload = "A lot of laughs"

    Sink.handle_write(:input, %Buffer{payload: payload}, nil, state)

    assert_receive {:udp, _, @local_address, @local_port_no, ^payload}
  end
end
