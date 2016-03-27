#!/usr/bin/ruby

require 'cinch'
require 'yaml'

$configfile = "config/hsdndbot.yml"

class Cinch::HSDnD
  include Cinch::Plugin

  ##
  ## Bot Actions
  ##

  ## Message matches
  match /help$/,                    method: :help
  match /roll$/,                    method: :roll
  match /roll (\d*)$/,              method: :roll
  match /races$/,                   method: :printallraces
  match /attrs$/,                   method: :printallattrs
  match /skills$/,                  method: :printallskills
  match /classes$/,                 method: :printallclasses
  match /classdeets (\w*)$/,        method: :printdetailedclass
  match /new$/,                     method: :new_player
  match /player (\w*) (\w*)$/,      method: :mod_player
  match /player (\w*) (\w*) (.*)$/, method: :mod_player
  match /skillroll (\w*)$/,         method: :skill_roll
  match /skillroll (\w*) (\d*)$/,   method: :skill_roll
  match /name$/,                    method: :set_player_name
  match /name (.*)$/,               method: :set_player_name
  match /backstory$/,               method: :set_player_backstory
  match /backstory (.*)$/,          method: :set_player_backstory
  match /race$/,                    method: :set_player_race
  match /race (\w*)$/,              method: :set_player_race
  match /class$/,                   method: :set_player_base_class
  match /class (\w*)$/,             method: :set_player_base_class

  ##
  ## Methods
  ##

  # Print a list of the existing functions
  def help (msg)
    msg.reply "!help, !roll, !races, !attrs, !skills, !new, !player"
  end

  # Roll a dice. Defaults to 12
  def roll (msg, num=nil)
    num &&= num.to_i
    num ||= 20
    msg.reply "#{msg.user.nick} rolled #{(rand num).to_s.to_i}"
  end

  # Make a roll for a particular skill
  def skill_roll (msg, skill_name, num=nil)
    # Set some defaults
    num &&= num.to_i
    num ||= 20

    # Get the player
    player = verify_player msg
    return unless player

    # Check that the skill exists
    skill = player.skill_exists? skill_name
    unless skill
      msg.reply "I'm sorry, #{skill_name} is not a valid skill."
      return
    end

    # Finally we make a role
    msg.reply "#{msg.user.nick} rolled #{skill.roll num}"
  end

  # Print all available attributes
  def printallattrs(msg)
    msg.reply "Listing available attributes:"
    Physattr.each { |p| msg.reply p }
    msg.reply "Done!"
  end

  # Print all available races
  def printallraces(msg)
    msg.reply "Listing available races:"
    Race.each { |r| msg.reply r }
    msg.reply "Done!"
  end

  # Print all skills
  def printallskills(msg)
    msg.reply "Listing available skills:"
    Skill.each { |s| msg.reply s }
    msg.reply "Done!"
  end

  # Print all base classes
  def printallclasses(msg)
    msg.reply "Listing available classes:"
    Basetype.each { |c| msg.reply c }
    msg.reply "Done!"
    msg.reply "Use !class NAME for more details."
  end

  # Print detailed class
  def printdetailedclass(msg, c_name)
    c = Basetype.where(name: c_name).first
    if c 
      msg.reply "Name: #{c.name}\nSummary: #{c.summary}\nUsual Roles: #{c.usualRoles.join(', ')}."
    else
      msg.reply "I'm sorry, that is not a valid class."
    end
  end

  # Check if the player already exists, and kindly tells user to create one if necessary.
  def get_player(msg)
    nick = msg.user.nick
    player = Player.nick_exists? nick
    # Check that the player exists
    unless player
      msg.reply "#{nick} does not have a character yet."
      msg.reply "Use !new to get started."
      return nil
    end
    player
  end

  # Checks if the user already has a player.
  # Checks if there are any more mandatory things to set (like race, etc)
  # Returns the user's player object if valid
  # Returns nil if the player does not have a character, or it is not ready
  # Also prints some helpful messages to the user
  def verify_player(msg)
    nick = msg.user.nick
    player = get_player msg
    return nil unless player
    # Check that the player is ready for use.
    # The idea is to tell the user everything he needs to set, all at once.
    ready = true
    unless player.name
      msg.reply "#{nick} does not have a name yet!"
      msg.reply "Spare yourself an existential crisis and set a name with !name."
      ready = false
    end
    unless player.backstory
      msg.reply "#{nick} does not have a backstory!"
      msg.reply "Who even are you? Tell us with !player set backstory."
      ready = false
    end
    unless player.race
      msg.reply "#{nick} has no race!"
      msg.reply "Use !player set race to forever idetifiy as a single stereotype."
      msg.reply "Use !races to get a list the playable races."
      ready = false
    end
    unless player.baseType
      msg.reply "#{nick} has no base class!"
      msg.reply "High school is full of cliques. Now choose one with !player set class."
      msg.reply "Use !classes to get a list of the playable classes."
      ready = false
    end
    ready ? player : nil
  end

  # Modify a character
  # This function checks if the user has a character,
  # And then fires off the get/set functions
  def mod_player(msg, action, field, value=nil)
    player = verify_player msg
    return unless player
    case action
      when /set|add/
        set_player_field(msg, player, field, value)
      when /get/
        get_player_field(msg, player, field)
      else
        msg.reply "Sorry, that action is not avaliable. :("
    end
  end

  # Set a player name
  def set_player_name(msg, name=nil)
    player = get_player msg
    unless name
      msg.reply player.name
      return
    end
    if player.name
      msg.reply "The majestic #{player.name} refuses to change his name!"
      return
    end
    player.name = name
    player.save
    msg.reply "Welcome, #{player.name}!"
  end

  # Set a player backstory
  def set_player_backstory(msg, backstory=nil)
    player = get_player msg
    unless backstory
      msg.reply player.backstory
      return
    end
    if player.backstory
      msg.reply "We've already heard of your epic upbringing."
      return
    end
    player.backstory = backstory
    player.save
    msg.reply "Kinda lame, but it will do."
  end

  # Set a player race
  def set_player_race(msg, race=nil)
    player = get_player msg
    unless race
      msg.reply player.race
      return
    end
    if player.race
      msg.reply "You can't change your ugly mug, and you can't change your race."
      return
    end
    if player.setRace race
      player.save
      msg.reply "It is up to you to embody the #{player.race.downcase} stereotypes!"
    else
      msg.reply "Sorry... we don't let weirdos play."
      msg.reply "Use !races to get the list of playable races."
    end
  end

  # Set a player base class
  def set_player_base_class(msg, class_name=nil)
    player = get_player msg
    unless class_name
      msg.reply player.baseType
      return
    end
    if player.baseType
      msg.reply "You've already picked your lot in life."
      return
    end
    if player.setBase class_name
      player.save
      msg.reply "It is up to you to embody the #{player.baseType.downcase} stereotypes!"
    else
      msg.reply "Sorry... we don't let weirdos play."
      msg.reply "Use !classes to get the list of player classes."
    end
  end

  # Set some character field
  def set_player_field(msg, player, field, value)
    case field
    when /skill/
      # Check that the player has skill points to spend
      unless player.skillPoints > 0
        msg.reply "You don't have any skill points left. :("
        return
      end
      # Add a skill point for that skill
      if player.skillup skill_name
        player.skillPoints -= 1
        msg.reply "Done!"
      else
        msg.reply "I'm sorry, that is not a valid skill. :("
      end
    else
      msg.reply "Sorry, that action is not available. :("
      return
    end
  end

  # Get a character field
  def get_player_field(msg, player, field)
    case field
    when /level/
      msg.reply player.level
    when /name/
      if player.name
        msg.reply player.name
      else
        msg.reply "Sorry, you do not have a name yet."
        msg.reply "Use !player set name to give your character a name."
      end
    when /race/
      if player.race
        msg.reply player.race
      else
        msg.reply "Sorry, you do not have a race yet."
        msg.reply "Use !player set race to choose your race."
      end
    when /class/
      if player.baseType
        msg.reply player.baseType
      else
        msg.reply "Sorry, you do not have a base class yet."
        msg.reply "Use !player set class to choose your class."
      end
    else
      msg.reply "Sorry, that action is not available. :("
      return
    end
  end

  # Create a new player
  def new_player(msg)
    nick = msg.user.nick
    # Check if the user already has a character
    if Player.nick_exists? nick
      msg.reply "#{nick} already has a character!"
      return
    end
    # Make a new one
    Player.new_player(nick).save
    msg.reply "Created new character for #{nick}!"
    msg.reply "To give your character a name, use: !player set name NAME"
    msg.reply "To give your character a race, use: !player set race RACE"
    msg.reply "To add a backstory, use: !player set backstory BACKSTORY"
  end
end

# Load up our configuration file
config = YAML::load_file($configfile)
bot = Cinch::Bot.new do
  configure do |c|
    c.nick = config[:bot][:nick]
    c.server = config[:bot][:server]
    c.channels = config[:bot][:channel]
    c.messages_per_second = 2
    c.plugins.plugins = [Cinch::HSDnD]
  end
end
bot.start
