# LogMon

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `log_mon` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:log_mon, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
    %{
      path_to_monitor: "/Users/user/logs/app.log",
      desired_file_size: 1024,
      compression: true,
      max_storage_count: 4,
      storage_path: "/Users/user/logs/backups/app",
      storage_file_name: "test_name",
      include_ts: true
    }

```
### 1. Keep log from using all storage.
path_to_monitor -> "full/path/to/log"
desired_file_size -> size in bites: 1024,
compression: true -> on or off,
max_storage_count -> this is the number of backups to be kept: 4,
storage_path -> "full/path/to/backups_dir",
storage_file_name -> each logging process must have a unique name: "test_name",
include_ts -> this allows the backup file names to contain timestamp info: true


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/log_mon>.

