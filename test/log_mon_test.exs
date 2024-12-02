defmodule LogMonTest do
  use ExUnit.Case
  doctest LogMon

  test "test_template" do
    assert LogMon.template_by_size() == %{
             compression: true,
             desired_file_size: 1024,
             include_ts: true,
             max_storage_count: 4,
             path_to_monitor: "/full/path/filename.log",
             storage_file_name: "unique_name",
             storage_path: "/full/path"
           }
  end
end
