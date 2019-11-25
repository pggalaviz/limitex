# Limitex

[![Build Status](https://travis-ci.org/pggalaviz/limitex.svg?branch=master)](https://travis-ci.org/pggalaviz/limitex)

A pure Elixir distributed rate limiter based on the
[Token Bucket](https://en.wikipedia.org/wiki/Token_bucket) algorithm.

## Description

**Limitex** uses sharded ETS tables with write and read concurrency enabled, node
clustering is not handled by this package, something like [libcluster](https://github.com/bitwalker/libcluster) is recomended.

#### Example

```elixir
=> Limitex.check_rate("127.0.0.1", 60_000, 2)
{:ok, 1}
=> Limitex.check_rate("127.0.0.1", 60_000, 2)
{:ok, 2}
=> Limitex.check_rate("127.0.0.1", 60_000, 2)
{:error, :rate_limited}
```


## Installation

You can find **Limitex** in [Hex.pm](https://hex.pm/packages/limitex) and you can add it to your project dependencies:

```elixir
# mix.exs
def deps do
  [
    {:limitex, "~> 0.1.1"}
  ]
end
```
## Configuration

**Limitex** will perform scheduled cleanups to remove expired buckets, to handle
this, we should provide a cleanup interval and an expiry:

```elixir
# config.exs

config :limitex,
  cleanup_interval: 60_000, # 1 minute (defaults to 5 minutes)
  expiry: 300_000 # 5 minutes (defaults to 15 minutes)
```

Table cleanups will be scheduled every minute in this example (defaults to 5
minutes), and will delete buckets where expiry has already passed, it's
important to give a value greater than the biggest bucket we create (the
bucket_time param in `check_rate` function, see below).

So if we're creating a bucket of 1 hour: `Limitex.check_rate("some_id",
3_600_000, 20)` we should give a bigger number in our config to prevent cleanup
to delete buckets which are not yet expired:

```elixir
# config.exs

config :limitex,
  expiry: 3_800_000
```

`expiry` defaults to 15 minutes.

## Usage

**Limitex** exports a single function: `check_rate/3` and `check_rate/4`.

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

## Examples

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

## Benchmarks

Basic benchmarks can be run with `mix bench`.

These benchmarks were run on an iMac 4 GHz Intel Core i7 w/ 32GB RAM.

```shell
Name                             ips        average  deviation         median         99th %
check_rate (100,000)        388.48 K        2.57 μs   ±892.63%        1.98 μs        4.98 μs
check_rate (1,000,000)      395.01 K        2.53 μs   ±898.74%           2 μs           4 μs
```
