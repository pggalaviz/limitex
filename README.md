# Limitex

A pure Elixir distributed rate limiter based on the
[Token Bucket](https://en.wikipedia.org/wiki/Token_bucket) algorithm.

**Limitex** uses sharded ETS tables with write and read concurrency enabled, node
clustering is not handled, something like **libcluster** is recomended.

## Installation

You can add this package to your project dependencies:

```elixir
# mix.exs
def deps do
  [
    {:limitex, "~> 0.1.1"}
  ]
end
```

## Usage

Limitex exports a single function: `check_rate/3` and `check_rate/4`.

* `check_rate(id, bucket_time, limit)`
* `check_rate(id, bucket_time, limit, increment)`

which return an `{:ok, count}` or `{:error, :rate_limited}` tuples.

#### Parameters

* `id` is a string to identify who's requesting the action, it can be
composed of a unique part such as an IP address or a user ID, plus some action
identifier (see example below).

* `bucket_time` is the amount of time you want to rate limit the action for the ID, must
  be given in milliseconds.

* `limit` is an integer which determines how many times we're allowed to perform
  the action in the given time.

* `increment` each time you call the function, the count to reach the limit is
  increased by 1 as a default, you can alternatively pass an arbitrary integer
  to increase the limit.

#### Examples

Inside your app you can call it inside any function:

```elixir
defmodule MyApp.Upload do

  def upload(video_data, user_id) do
    case Limitex.check_rate("upload:#{user_id}", 60_000, 5) do
      {:ok, _count} ->
        # upload the video, somehow
      {:error, :rate_limited} ->
        # deny the request
    end
  end

end
```

So in the above example we'll limit user's uploads to 5 every 60 seconds.

#### Configuration

**Limitex** will perform scheduled cleanups to remove expired buckets, to handle
this, we should provide a cleanup interval and an expiry:

```elixir
# inside config.exs

config :limitex,
  cleanup_interval: 60_000,
  expiry: 300_000
```

Table cleanups will be scheduled every minute in this example (defaults to 5
minutes), and will delete buckets where expiry has already passed, it's
important to give a value greater than the biggest bucket we create (the
bucket_time param in `check_rate` function).

So if we're creating a bucket of 1 hour: `Limitex.check_rate("some_id",
3_600_000, 20)` we should give a bigger number in our config to prevent cleanup
to delete buckets which are not yet expired:

```elixir
# inside config.exs

config :limitex,
  expiry: 3_800_000
```

`expiry` defaults to 15 minutes.

#### Benchmarks

Basic benchmarks can be run with `mix bench`.
