use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: :dev

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"x%)JpXPon]_./;zFZf6!dhX8C?W]OsH9<6IIImoFO_v&KPaiSZx/MK)@?wSmbZ<U"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"Upe^_W<?UzCQm{EH2D:/mYyo9,Ikf/u`yB(w{g6@1o@Q__/b]ze}o%bNOU@,?2z3"
  # Other settings
  set output_dir: "rel/multas"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :multas do
  set version: current_version(:multas)
end
