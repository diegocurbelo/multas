defmodule Multas do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    Multas.Metrics.PhoenixInstrumenter.setup()
    Multas.Metrics.PipelineInstrumenter.setup()
    Multas.Metrics.RepoInstrumenter.setup()
    if {:unix, :linux} == :os.type do
      Prometheus.Registry.register_collector(:prometheus_process_collector)
    end
    Multas.Metrics.PrometheusExporter.setup()

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Multas.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Multas.Endpoint, []),
      # Start your own worker by calling: Multas.Worker.start_link(arg1, arg2, arg3)
      # worker(Multas.Worker, [arg1, arg2, arg3]),
      worker(ImpoParser, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Multas.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Multas.Endpoint.config_change(changed, removed)
    :ok
  end
end
