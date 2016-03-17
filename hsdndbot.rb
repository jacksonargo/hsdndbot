#!/usr/bin/ruby

require 'cinch'
require 'mongo'
require 'yaml'
require 'hsdnd'

$configfile = "config/hsdndbot.yml"

class Cinch::HSDnD
  include Cinch::Plugin

  ##
  ## Bot Actions
  ##

  ## Message matches
  match /help$/,                  method: :help
  match /roll(.*)$/,              method: :roll
  match /races$/,                 method: :printallraces
  match /attrs$/,                 method: :printallattrs
  match /skills$/,                method: :printallskills
  match /new$/,                   method: :new_player
  match /player (\w*) (\w*)$/,      method: :mod_player
  match /player (\w*) (\w*) (.*)$/, method: :mod_player

  ##
  ## Methods
  ##

  # Modify a character
  def mod_player(msg, action, field, value=nil)
    nick = msg.user.nick
    player = Player.nick_exists? nick
    unless player
      msg.reply "#{nick} does not have a character yet."
      msg.reply "Use !new to get started."
      return
    end
    case action
      when /set|add/
        set_player_field(msg, player, field, value)
      when /get/
        get_player_field(msg, player, field)
      else
        msg.reply "Sorry, that action is not avaliable. :("
    end
    return
  end

  # Set some character field
  def set_player_field(msg, player, field, value)
    case field
    when /race/
      if player.setRace value
        msg.reply "It is up to you to embody the #{value.downcase} stereotypes!"
      else
        msg.reply "Sorry... we don't let weirdos play."
        msg.reply "Use !races to get the list of playable races."
      end
    when /class/
      if player.setBase value
        msg.reply "It is up to you to embody the #{value.downcase} stereotypes!"
      else
        msg.reply "Sorry... we don't let weirdos play."
        msg.reply "Use !classes to get the list of player classes."
      end
    else
      msg.reply "Sorry, that action is not available. :("
      return
    end
  end

  def update_character_skill(msg, player, skill)
    # Check that the player has skill points to spend
    unless player.skillPoints > 0
      msg.reply "You don't have any skill points left. :("
      return
    end
    # Add a skill point for that skill
    if player.addSkill skill
      player.skillPoints -= 1
      msg.reply "Done!"
    else
      msg.reply "I'm sorry, that is not a valid skill. :("
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
        msg.reply "Sorry, you do not have a name yet."
        msg.reply "Use !player set race to choose your race."
      end
    when /class/
      if player.baseType
        msg.reply player.baseType
      else
        msg.reply "Sorry, you do not have a base class yet."
        msg.reply "Use !player set class to choose your class."
      end
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

  # Print all available races
  def printallraces(msg)
    msg.reply "Listing available races:"
    Race.each { |r| msg.reply r }
    msg.reply "Done!"
  end

  # Print available skills for particular attribute
  def printskillsforattr(msg, attri=nil)
    attri = unabrevattr attri
    unless attri
      msg.reply "Usage: !skills ATTRIBUTE"
      printallattrs msg
      return
    end
    skills = @db[:skills].find({attribute: attri})
    unless skills
      printallattrs msg
      return
    end
    msg.reply "Available skills for #{attri}:"
    skills.each do |s|
      message = "#{s[:name]}: "
      message += "#{s[:description]} "
      message += "Related attribute: #{s[:attribute]}."
      msg.reply message
      sleep 0.5
    end
  end

  # Print all skills
  def printallskills(msg)
  msg.reply "Listing available skills"
  @db[:skills].find().each do |s|
      message = "#{s[:name]}: "
      message += "#{s[:description]}"
      message += "." unless message[-1] == "." # Add a period when necessary.
      message += " "
      message += "Related attribute: #{s[:attribute]}."
      msg.reply message
      sleep 0.5
    end
  msg.reply "Done!"
  end

  # Print all available attributes
  def printallattrs(msg)
    msg.reply "Listing available attributes:"
    @db[:attrs].find().each do |a|
      msg.reply "(#{a[:short]}) #{a[:name]}"
    end
    msg.reply "Done!"
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
