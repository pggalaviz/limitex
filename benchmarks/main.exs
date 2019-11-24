{:ok, _} = Application.ensure_all_started(:limitex)

benchmarks = %{
  "check_rate (100,000)" => fn ->
    Limitex.check_rate("127.0.0.1", 120_000, 100000)
  end,
  "check_rate (1,000,000)" => fn ->
    Limitex.check_rate("127.0.0.2", 120_000, 1000000)
  end
}

Benchee.run(benchmarks, [
  formatters: [
    {Benchee.Formatters.Console, comparison: false, extended_statistics: true}
  ],
  print: [
    fast_warning: false
  ]
])
