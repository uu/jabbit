Gem::Specification.new do |s|
  s.name        = 'jabbit'
  s.version     = '0.0.1'
  s.date        = '2013-01-20'
  s.summary     = "Jabber via RabbitMQ proxy."
  s.description = "Jabbit takes encrypted json messages from rabbitmq query and push it to jabber connection"
  s.authors     = ["Igor Loskutoff"]
  s.email       = 'igor.loskutoff@gmail.com'
  s.files = Dir['lib/**/*'] + Dir['bin/*']

  s.add_dependency('xmpp4r', '>= 0.5')
  s.add_dependency('bunny', '>= 0.8.0')
  s.add_dependency('settingslogic', '>= 2.0.6')

  s.executables << 'jabbit'
  
end
