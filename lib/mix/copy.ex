defmodule Mix.Tasks.Outerfaces.Copy do
  @moduledoc """
  Copies files from the source_dir to the target_dir.
  First clears the target directory.
  """
  use Mix.Task
  @base_dir "./"

  @doc """
  Copies files from the source_dir to the target_dir.
  First clears the target directory.
  """
  @shortdoc "Copies files from the source_dir to the target_dir"
  @spec run(args :: list(String.t())) :: :ok
  def run(args \\ []) when is_list(args) do
    opts = parse_args(args)
    source_base_path = Keyword.get(opts, :source_base_path, @base_dir)

    copy_files(
      Keyword.get(opts, :source_dir),
      Keyword.get(opts, :target_dir),
      source_base_path
    )
  end

  defp parse_args(args) when is_list(args) do
    Enum.reduce(args, [], fn arg, acc ->
      [key, value] = String.split(arg, "=")
      [{String.to_atom(key), value} | acc]
    end)
  end

  @spec copy_files(source_dir :: String.t(), target_dir :: String.t()) :: :ok
  def copy_files(source_dir, target_dir)
      when is_binary(source_dir) and is_binary(target_dir) do
    full_target_dir_path = Path.expand(target_dir)
    File.rm_rf!(full_target_dir_path)
    File.mkdir_p!(full_target_dir_path)
    full_source_dir_path = Path.expand(source_dir)
    File.cp_r!(full_source_dir_path, full_target_dir_path)
    :ok
  end

  def copy_files(source_dir, target_dir, base_dir)
      when is_binary(source_dir) and is_binary(target_dir) do
    with {:ok, full_source_dir_path} <- safe_path(source_dir, base_dir),
         {:ok, full_target_dir_path} <- safe_path(target_dir, base_dir) do
      File.rm_rf!(full_target_dir_path)
      File.mkdir_p!(full_target_dir_path)
      File.cp_r!(full_source_dir_path, full_target_dir_path)
    else
      {:error, msg} -> Mix.shell().error(msg)
    end
  end

  defp safe_path(path, base_dir) do
    full_path = Path.expand(path, base_dir)

    if String.starts_with?(full_path, Path.expand(base_dir)) do
      {:ok, full_path}
    else
      {:error, "Invalid path"}
    end
  end
end
