require 'settingslogic'
class Settings < Settingslogic
  source Gem::default_path[-1] + '/gems/jabbit-9999/lib/Jabbit/settings/application.yml'
end
