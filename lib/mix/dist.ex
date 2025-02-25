defmodule Mix.Tasks.Outerfaces.Dist do
  @moduledoc """
  Copies outerfaces projects to the priv/static/outerfaces directory
  """
  use Mix.Task
  @otp_app_config_key :outerfaces
  @source_dir "./outerfaces/"
  @target_dir "./priv/static/outerfaces"
  @target_base_path "./"

  @shortdoc "Copies all outerfaces projects to the priv/static/outerfaces directory"

  @doc """
  Copies all outerfaces projects to the priv/static/outerfaces directory
  """
  def run(args \\ []) do
    opts = parse_args(args)

    base_dir = Keyword.get(opts, :target_base_dir, @target_base_path)

    copy_all_assets(base_dir)

    if Keyword.get(opts, :do_copy_environment_files, false) do
      copy_environment_files()
    end

    Mix.shell().info("Outerface projects copied to #{@target_dir}")
  end

  defp copy_all_assets(base_dir) do
    Mix.Tasks.Outerfaces.Copy.run([
      "source_dir=#{@source_dir}",
      "target_dir=#{@target_dir}",
      "source_base_path=#{base_dir}"
    ])
  end

  defp parse_args(args) do
    Enum.reduce(args, [], fn arg, acc ->
      case String.split(arg, "=") do
        [key, value] -> [{String.to_atom(key), value} | acc]
        _ -> acc
      end
    end)
  end

  defp copy_environment_files do
    apps_config = Application.get_env(@otp_app_config_key, :apps, [])
    app_env_config = Application.get_env(@otp_app_config_key, :app_environments, [])

    Enum.each(apps_config, fn app ->
      case Keyword.get(app_env_config, String.to_atom(app)) do
        nil ->
          Mix.shell().info("No specific environment for #{app}, skipping.")

        env ->
          source_env_file = Path.join([@source_dir, "projects", app, "environments", "#{env}.js"])
          target_env_dir = Path.join([@target_dir, "projects", app, "environments"])
          target_env_file = Path.join(target_env_dir, "environment.js")

          clean_environment_dir(target_env_dir)

          if File.exists?(source_env_file) do
            File.mkdir_p!(Path.dirname(target_env_file))
            File.cp!(source_env_file, target_env_file)
            Mix.shell().info("Copied #{env}.js to #{target_env_file}")
          else
            Mix.shell().error("File not found at #{source_env_file}")
            Mix.shell().error("Environment file #{env}.js not found for #{app}.")
          end
      end
    end)
  end

  defp clean_environment_dir(target_env_dir) do
    if File.exists?(target_env_dir) do
      File.rm_rf!(target_env_dir)
    end
  end
end
