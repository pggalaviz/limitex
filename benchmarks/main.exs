{:ok, _} = Application.ensure_all_started(:limitex)

benchmarks = %{
  "check_rate" => fn ->
    Limitex.check_rate("120.0.0.1", 60_000, 1000)
  end,
}

Benchee.run(benchmarks, [
  console: [
    comparison: false,
    extended_statistics: true
  ],
  formatters: [
    Benchee.Formatters.Console
  ],
  print: [
    fast_warning: false
  ]
])
