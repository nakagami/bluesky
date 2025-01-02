defmodule Bluesky.Session do
  defstruct prefix: nil, data: nil

  @moduledoc """
  Documentation for `Bluesky.Session`.
  """

  @bluesky_prefix "https://bsky.social/xrpc/"

  defp _get(%__MODULE__{prefix: prefix, data: data}, path, params \\ nil, token \\ "accessJwt") do
    url = "#{prefix}#{path}"
    headers = [Authorization: "Bearer #{data[token]}"]
    response = HTTPoison.get!(url, params, headers)
    data = Poison.Parser.parse!(response.body)

    if Map.has_key?(data, "error") do
      {:ok, data}
    else
      {:error, data}
    end
  end

  defp _post(%__MODULE__{prefix: prefix, data: data}, path, params \\ nil, token = "accessJwt") do
    url = "#{prefix}#{path}"

    params =
      if is_map(params) do
        Poison.encode!(params)
      else
        params
      end

    headers = [
      "Content-Type": "application/json; charset=UTF-8",
      Authorization: "Bearer #{data[token]}"
    ]

    response = HTTPoison.post!(url, params, headers)

    if response.body == "" do
      {:ok, nil}
    else
      data = Poison.Parser.parse!(response.body)

      if Map.has_key?(data, "error") do
        {:ok, data}
      else
        {:error, data}
      end
    end
  end

  @doc """
  Create session.

  ## Examples

      iex> Bluesky.Session.create_session("XXX.bsky.social", "secret")
      {:ok, %Bluesky.Session{...}}
  """
  def create_session(identifier, password, prefix \\ @bluesky_prefix) do
    url = "#{prefix}com.atproto.server.createSession"
    headers = ["Content-Type": "application/json; charset=UTF-8"]
    body = Poison.encode!(%{identifier: identifier, password: password})
    response = HTTPoison.post!(url, body, headers)
    data = Poison.Parser.parse!(response.body)

    ok_error =
      if response.status_code == 200 do
        :ok
      else
        :error
      end

    {ok_error, %__MODULE__{prefix: prefix, data: data}}
  end
end
