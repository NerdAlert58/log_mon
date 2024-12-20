defmodule LogMon do
  @moduledoc """
      LogMon is a hat tip to logrotate.


      ```elixir
      LogMon.run("/path/to/config")
      LogMon.run(config)
      ```

      LogMon.run(path) -> path: "/path/to/config"
      LogMon.run(config) -> config: %{
                                        path_to_monitor: "/home/user/logs/app.log",
                                        desired_file_size: 1024,
                                        compression: true,
                                        max_storage_count: 4,
                                        storage_path: "/home/user/logs/backups/app",
                                        storage_file_name: "app_name",
                                        include_ts: true
                                    })

  > [!NOTE]
  > %LogMon.Config{}

      > path_to_monitor
        > This is the path to the log file and should include the filename and extension.
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

      The following will check a "path_to_monitor"
      to see if that file exists and if it happens to be larger than "desired_file_size"
      If it is, it will make a copy of the "path_to_monitor"
      at "storage_path"
      using "storage_file_name"
      + .log
      OR
      + <timestamp>.log 
      If "include_ts"
      is set to true.
      Then, it will check the "storage_path"
      to see how many files are named according to our matching and if that is larger than "max_storage_count"
      then it will remove delete the oldest files down to the value supplied.

  """

  require Logger

  # @doc """
  # Takes either a full path to a config file or the map of the same.
  #
  #     iex(1)> LogMon.run(
  #     %{
  #       path_to_monitor: "/home/user/logs/app.log",
  #       desired_file_size: 1024,
  #       compression: true,
  #       max_storage_count: 4,
  #       storage_path: "/home/user/logs/backups/app",
  #       storage_file_name: "app_name",
  #       include_ts: true
  #     })
  # """
  @doc """
  Takes either a full path to a config file or the map of the same.

  ## Example




  """
  def run(path) when is_binary(path) do
    case valid_config_path?(path) do
      {:error, reason} ->
        Logger.error("Failed to read config file due to: #{reason}")

      config ->
        run(config)
    end
  end

  def run(config) when is_map(config) do
    result =
      config
      |> valid_config?()
      |> check_current_log_size()
      |> check_backup_count(true)

    {:ok, result}
  end

  def template_by_size() do
    %{
      path_to_monitor: "/full/path/filename.log",
      desired_file_size: 1024,
      compression: true,
      max_storage_count: 4,
      storage_path: "/full/path",
      storage_file_name: "unique_name",
      include_ts: true
    }
  end

  @doc """
  Takes either a full path to a config file or the map of the same.

      iex(1)> logmon.test
      %{
        path_to_monitor: "/home/user/logs/app.log",
        desired_file_size: 1024,
        compression: true,
        max_storage_count: 4,
        storage_path: "/home/user/logs/backups/app",
        storage_file_name: "app_name",
        include_ts: true
      }
  """
  def template do
    # %{
    #   path_to_monitor: "/Users/user/logs/app.log",
    #   desired_file_size: 1024,
    #   compression: true,
    #   max_storage_count: 4,
    #   storage_path: "/Users/user/logs/backups/app",
    #   storage_file_name: "app_name",
    #   include_ts: true
    # }
    IO.inspect("Use this template if log file starts at empty and grows until forever.")
    template_by_size()
  end

  # def template_by_frequency() do
  #   %{
  #     path_to_monitor: "/full/path/filename.log",
  #     backup_time_24_hr: ~T[04:00:00.001],
  #     compression: true,
  #     max_storage_count: 4,
  #     storage_path: "/full/path",
  #     storage_file_name: "unique_name",
  #     include_ts: true
  #   }
  # end
  #
  defp valid_config_path?(path) do
    case File.read(path) do
      {:ok, file} ->
        case Jason.decode(file) do
          {:ok, config} ->
            config

          {:error, reason} ->
            {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp valid_config?(
         %{
           path_to_monitor: _path_to_monitor,
           desired_file_size: _desired_file_size,
           compression: _compress,
           max_storage_count: _max_storage_count,
           storage_path: _storage_path,
           storage_file_name: _storage_file_name,
           include_ts: _include_ts
         } = config
       ) do
    config
    |> valid_path_to_monitor()
    |> valid_file_size?()
    |> valid_compression?()
    |> valid_max_storage_count?()
    |> valid_storage_path?()
    |> valid_storage_file_name?()
    |> valid_include_ts?()
    |> valid_results?()
  end

  def valid_results?(config) do
    {_pass, fail} =
      config.validation
      |> Enum.split_with(fn {_, parts} -> parts == :pass end)

    if length(fail) > 0 do
      Logger.warning("Fails found issue")

      fail
      |> Enum.each(fn {key, value} ->
        Logger.warning("#{key} reported #{value}")
      end)
    end

    # if length(pass) > 0 do
    #   results =
    #     Enum.map(pass, fn {key, _} ->
    #       # Enum.member?(
    #       #   [
    #       #     :path_to_monitor,
    #       #     :desired_file_size,
    #       #     :compression,
    #       #     :max_storage_count,
    #       #     :storage_path,
    #       #     :storage_file_name
    #       #   ],
    #       #   key
    #       # )
    #       key
    #     end)
    #
    #   IO.inspect(pass, label: "Pass")
    # end

    config
  end

  defp valid_path_to_monitor(%{path_to_monitor: path_to_monitor} = config) do
    case File.exists?(path_to_monitor) do
      true ->
        File.stat!(path_to_monitor)
        log_step_result(config, :path_to_monitor, :pass)

      false ->
        case File.mkdir_p(path_to_monitor) do
          :ok ->
            log_step_result(config, :path_to_monitor, :pass)

          {:error, reason} ->
            {:error, "#{path_to_monitor} could not be created: #{reason}"}
            log_step_result(config, :path_to_monitor, :err)
        end
    end
  end

  defp valid_file_size?(%{desired_file_size: desired_file_size} = config) do
    case desired_file_size do
      x when is_number(x) ->
        # if x > 1024 * 1024 do
        if x >= 1 do
          log_step_result(config, :desired_file_size, :pass)
        else
          log_step_result(config, :desired_file_size, :err)
        end
    end
  end

  defp valid_compression?(%{compression: compression} = config) do
    case is_boolean(compression) do
      true -> log_step_result(config, :compression, :pass)
      false -> log_step_result(config, :compression, :err)
    end
  end

  defp valid_max_storage_count?(%{desired_file_size: desired_file_size} = config) do
    case desired_file_size do
      x when is_number(x) ->
        if x > 0 do
          log_step_result(config, :max_storage_count, :pass)
        else
          log_step_result(config, :max_storage_count, :err)
        end
    end
  end

  defp valid_storage_path?(%{storage_path: storage_path} = config) do
    case File.stat(storage_path) do
      {:ok, _} ->
        log_step_result(config, :storage_path, :pass)

      {:error, :enoent} ->
        case File.mkdir_p(storage_path) do
          :ok ->
            log_step_result(config, :storage_path, :pass)

          {:error, reason} ->
            {:error, "#{storage_path} could not be created: #{reason}"}
            log_step_result(config, :storage_path, :err)
        end

      {:error, _} ->
        log_step_result(config, :storage_path, :err)
    end
  end

  defp valid_storage_file_name?(%{storage_file_name: storage_file_name} = config) do
    case storage_file_name do
      nil ->
        log_step_result(config, :storage_file_name, :err)

      "" ->
        log_step_result(config, :storage_file_name, :err)

      x when is_binary(x) ->
        # TODO: Add cases for characters that shouldn't be in a filename?
        log_step_result(config, :storage_file_name, :pass)

      _ ->
        log_step_result(config, :storage_file_name, :err)
    end
  end

  defp valid_include_ts?(%{include_ts: include_ts} = config) do
    case is_boolean(include_ts) do
      true -> log_step_result(config, :include_ts, :pass)
      false -> log_step_result(config, :include_ts, :err)
    end
  end

  defp build_storage_path(storage_path, storage_file_name, include_ts) do
    case include_ts do
      true ->
        case DateTime.now("Etc/UTC") do
          {:ok, datetime} ->
            {:ok,
             "#{storage_path}/#{storage_file_name}_#{datetime.year}#{datetime.month}#{datetime.day}_#{datetime.hour}#{datetime.minute}#{datetime.second}.log"}
        end

      false ->
        {:ok, "#{storage_path}/#{storage_file_name}.log"}
    end
  end

  defp check_current_log_size(
         %{
           path_to_monitor: path_to_monitor,
           desired_file_size: desired_file_size,
           compression: compression,
           max_storage_count: _max_storage_count,
           storage_path: storage_path,
           storage_file_name: storage_file_name,
           include_ts: include_ts
         } = config
       ) do
    case File.stat(path_to_monitor) do
      {:ok, %{size: size}} ->
        case size >= desired_file_size do
          true ->
            Logger.info("Size: #{size} >= MaxSize: #{desired_file_size}")

            case build_storage_path(storage_path, storage_file_name, include_ts) do
              {:ok, output_path} ->
                case File.copy(path_to_monitor, output_path) do
                  {:ok, bytes} ->
                    case File.exists?(output_path) do
                      true ->
                        config = log_step_result(config, :file_copied, :pass)
                        Logger.info("Log copied: #{output_path} size: #{bytes}")

                        config =
                          case File.write(path_to_monitor, "", [:write]) do
                            :ok ->
                              log_step_result(config, :file_copied, :pass)

                            {:error, _reason} ->
                              log_step_result(config, :file_copied, :err)
                          end

                        config =
                          if compression do
                            case compress_file(output_path, storage_file_name) do
                              :ok ->
                                log_step_result(config, :file_compressed, :pass)

                              {:error, reason} ->
                                Logger.error(
                                  "failed to compress file: #{storage_file_name} due to error: #{reason}"
                                )

                                log_step_result(config, :file_compressed, :err)
                            end
                          end

                        config

                      false ->
                        Logger.error("Failed to locate file: #{output_path}")
                        log_step_result(config, :backup_log, :err)
                    end

                  {:error, error} ->
                    Logger.error("failed to copy file: #{path_to_monitor} due to error: #{error}")
                    log_step_result(config, :file_copied, :pass)
                end
            end

          _ ->
            log_step_result(config, :backup_log, :noop)
        end
    end

    config
  end

  # @doc """
  #   **file_path** expects the full path to the file
  #
  #   **compressed_file_name** will append a ".log" to the end of the value here. "myBackup" would be saved as "myBackup.log"
  #
  # ```elixir
  #   LogMon.compress_file()
  # ```
  # """
  defp compress_file(file_path, compressed_file_name) do
    case File.read(file_path) do
      {:ok, content} ->
        compressed_content = :zlib.gzip(content)

        case File.write(compressed_file_name, compressed_content) do
          :ok ->
            :ok

          {:error, reason} ->
            {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp check_backup_count(
         %{
           max_storage_count: max_storage_count,
           storage_path: storage_path,
           storage_file_name: storage_file_name
         } = config,
         first_pass
       ) do
    with {:ok, files} <- File.ls(storage_path) do
      files_with_meta =
        files
        |> Enum.filter(&String.starts_with?(&1, storage_file_name))
        |> Enum.map(&file_info(storage_path, &1))

      case Enum.count(files_with_meta) do
        x when x > max_storage_count ->
          config =
            if first_pass do
              config
              |> log_step_result(:backup_count, x)
              |> remove_excess_backup(files_with_meta)
              |> check_backup_count(false)
            else
              config
              |> remove_excess_backup(files_with_meta)
              |> check_backup_count(false)
            end

          log_step_result(config, :backups, :pass)

        x when x <= max_storage_count ->
          Logger.info("#{x} <= #{max_storage_count}")
          log_step_result(config, :backups, :pass)

        _ ->
          Logger.info("What just happened?")
          log_step_result(config, :backups, :err)
      end
    else
      {:error, _reason} ->
        log_step_result(config, :backups, :err)
    end
  end

  defp remove_excess_backup(%{storage_path: storage_path} = config, files_with_meta) do
    [file | _] = Enum.sort_by(files_with_meta, & &1.modified_at, {:asc, Date})

    config =
      case File.rm(storage_path <> "/" <> file.name) do
        :ok -> log_step_result(config, :remove_file, :pass)
        {:error, _reason} -> log_step_result(config, :remove_file, :err)
      end

    config
  end

  defp file_info(directory, filename) do
    full_path = Path.join(directory, filename)

    {:ok, stat} = File.stat(full_path, time: :posix)

    %{
      name: filename,
      created_at: stat.ctime |> posix_to_naive_datetime(),
      modified_at: stat.mtime |> posix_to_naive_datetime()
    }
  end

  defp posix_to_naive_datetime(posix_time) do
    posix_time
    |> DateTime.from_unix!()
    |> DateTime.to_naive()
  end

  defp log_step_result(config, name, state) do
    Map.update(config, :validation, %{:name => state}, fn x -> Map.put(x, name, state) end)
  end
end
