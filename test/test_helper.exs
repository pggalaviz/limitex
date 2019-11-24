{:ok, _} = Application.ensure_all_started(:limitex)
ExUnit.configure(exclude: [:cluster])

include = Keyword.get(ExUnit.configuration(), :include, [])
if :cluster in include do
  # Turn node into a distributed node with the given long name
  :net_kernel.start([:"test@127.0.0.1"])
  {:ok, _} = Limitex.TestCluster.start()
else
  IO.puts("==> Running tests on single node, to run on cluster mode add: --include cluster")
end

ExUnit.start()
