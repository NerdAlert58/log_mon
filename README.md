# LogMon

**log_rotate was one of the first programs I "found".  I used it for years. Now I've decided to write one myself.**

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
LogMon.run("/path/to/config")
LogMon.run(config)
```
%LogMon.Config{}
```elixir
%{
  path_to_monitor: "/home/user/logs/app.log",
  desired_file_size: 1024,
  compression: true,
  max_storage_count: 4,
  storage_path: "/home/user/logs/backups/app",
  storage_file_name: "app_name",
  include_ts: true
})
```
> [!NOTE]
> I have spent way too much time, just trying to make the docs look ok and work.

%LogMon.Config{}

* path_to_monitor
  * This is the path to the log file and should include the filename and extension.
* desired_file_size
  * How large would you like your log to grow? (In Bs) 1024*1024*1024 == 1 Gb
* compression
  * Do you want the backups compressed? 
* max_storage_count
  * How many backups do you want to maintain?
* storage_path
  * path to where the backups will be kept
* storage_file_name
  * give this a unique value as this is how backups are identified and counted.
* include_ts
  * Do you want a timestamp in the log file name?  Of course.
```elixir
  %{
    path_to_monitor: "/home/user/logs/app.log",
    desired_file_size: 1024,
    compression: true,
    max_storage_count: 4,
    storage_path: "/home/user/logs/backups/app",
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

