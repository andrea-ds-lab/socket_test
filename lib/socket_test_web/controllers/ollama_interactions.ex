defmodule SocketTestWeb.OllamaInteraction do
  @moduledoc """
  A module to interact with the Ollama API.
  """

  @url "http://127.0.0.1:11223/api/generate"
  # Specify the model if needed
  @model "llama3-chatqa"
  # Limit the number of tokens in the response
  @max_tokens 10

  @doc """
  Interacts with the Ollama API using the given prompt.

  ## Parameters
  - prompt: A string representing the prompt for the API.

  ## Returns
  - A tuple with the status and response (either success or error).
  """
  def interact_with_ollama(prompt) do
    payload = %{
      model: @model,
      prompt: prompt,
      max_tokens: @max_tokens
    }

    IO.inspect(payload)

    headers = [{"Content-Type", "application/json"}]

    # Increase the timeout settings
    # Timeout set to 60 seconds
    options = [timeout: 60_000, recv_timeout: 60_000]

    case HTTPoison.post(@url, Jason.encode!(payload), headers, options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        handle_response(body)

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "Error: Received status #{status_code} with body #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Error: #{inspect(reason)}"}
    end
  end

  defp handle_response(body) do
    case combine_responses(body) do
      %{done: true, response: response} ->
        # Return the combined response
        {:ok, response}

      %{done: false, response: response} ->
        {:error, "Incomplete response: #{response}"}

      _ ->
        {:error, "Unexpected response format"}
    end
  end

  defp combine_responses(data) do
    data
    |> String.trim()
    |> String.split("\n")
    |> Enum.reduce(%{response: "", done: false}, fn line, acc ->
      case Jason.decode(line) do
        {:ok, %{"response" => response, "done" => done}} ->
          updated_response = acc.response <> " " <> response
          %{response: String.trim(updated_response), done: done}

        _ ->
          acc
      end
    end)
  end
end
