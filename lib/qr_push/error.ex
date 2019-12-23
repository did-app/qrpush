defmodule QrPush.Error do
  @enforce_keys [:status, :code, :title, :detail, :meta, :stacktrace]
  defstruct @enforce_keys

  defp new(status, code, title, detail, meta) do
    stacktrace = elem(Process.info(self(), :current_stacktrace), 1)

    %__MODULE__{
      status: status,
      code: code,
      title: title,
      detail: detail,
      meta: meta,
      stacktrace: stacktrace
    }
  end

  def to_data(error, tracing_id \\ nil) do
    %__MODULE__{
      status: status,
      code: code,
      title: title,
      detail: detail,
      meta: meta,
      stacktrace: _stacktrace
    } = error

    data = %{
      id: tracing_id,
      status: status,
      code: code,
      title: title,
      detail: detail,
      meta: meta
    }

    data
  end

  def operation_denied(detail, meta \\ %{}) do
    status = 400
    code = :operation_denied
    title = "Authentication was invalid"
    new(status, code, title, detail, meta)
  end

  def invalid_request(detail, meta \\ %{}) do
    status = 400
    code = :invalid_request
    title = "Request is invalid"
    new(status, code, title, detail, meta)
  end
end
