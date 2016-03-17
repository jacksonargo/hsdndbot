class Hsdnd
  require 'mongoid'
  require 'hsdnd/physattr'
  require 'hsdnd/race'
  require 'hsdnd/skill'
  require 'hsdnd/plyrclass'
  require 'hsdnd/player'
  Mongoid.load!("config/mongoid.yml", :development)
end
