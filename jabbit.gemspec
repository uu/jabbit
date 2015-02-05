Gem::Specification.new do |s|
  s.name = 'jabbit'
  s.version = '0.0.2'
  s.date = '2013-01-20'
  s.summary = 'Jabber via RabbitMQ proxy.'
  s.description = 'Jabbit takes encrypted json messages from rabbitmq query and push it to jabber connection'
  s.homepage = 'http://github.com/uu/jabbit'
  s.authors = ['Michael Pirogov']
  s.email = 'vbnet.ru@gmail.com'
  s.files = Dir['lib/**/*'] + Dir['bin/*']

  s.add_dependency('xmpp4r', '>= 0.5')
  s.add_dependency('bunny', '>= 1.6.3')
  s.add_dependency('settingslogic', '>= 2.0.6')

  s.executables << 'jabbit'

end
