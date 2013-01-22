require 'settingslogic'
class Settings < Settingslogic
  source "#{Dir.pwd}/lib/Jabbit/settings/application.yml"
end
