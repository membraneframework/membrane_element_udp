defmodule Membrane.Element.UDP.Socket do
  @moduledoc false

  defstruct [:port_no, :ip_address, :socket_handle]

  @type t :: %__MODULE__{
          port_no: :inet.port_number(),
          ip_address: :inet.socket_address(),
          socket_handle: :gen_udp.socket()
        }

  @spec open(socket :: t()) :: {:ok, t()} | {:error, :inet.posix()}
  def open(%__MODULE__{port_no: port_no, ip_address: ip} = socket) do
    case :gen_udp.open(port_no, [{:ip, ip}, :binary, {:active, true}]) do
      {:ok, socket_handle} -> {:ok, %__MODULE__{socket | socket_handle: socket_handle}}
      error -> error
    end
  end

  @spec close(socket :: t()) :: t()
  def close(%__MODULE__{socket_handle: handle} = socket) when is_port(handle) do
    :gen_udp.close(handle)
    %__MODULE__{socket | socket_handle: handle}
  end

  @spec send(target :: t(), source :: t(), payload :: Membrane.Payload.t()) ::
          :ok | {:error, :not_owner | :inet.posix()}
  def send(
        %__MODULE__{port_no: target_port_no, ip_address: target_ip},
        %__MODULE__{socket_handle: socket_handle},
        payload
      )
      when is_port(socket_handle) do
    :gen_udp.send(socket_handle, target_ip, target_port_no, payload)
  end
end
