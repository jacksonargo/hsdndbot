#!/usr/bin/ruby

require 'cinch'
require 'mongo'
require 'yaml'

$configfile = "hsdndbot.conf.yml"

class Cinch::HSDnD
  include Cinch::Plugin

  ##
  ## Bot Actions
  ##

  ## Timers
  timer 1, {  method: :dbconnect, shots: 1 } # Connect to the db

  ## Message matches
  match /help$/,                  method: :help
  match /roll(.*)$/,              method: :roll
  match /races$/,                 method: :printallraces
  match /attrs$/,                 method: :printallattrs
  match /skills$/,                method: :printallskills
  match /new$/,                   method: :new_character 
  match /player (\w*) (\w*)$/,      method: :mod_character
  match /player (\w*) (\w*) (.*)$/, method: :mod_character

  ##
  ## Methods
  ##

  # Modify a character
  def mod_character(msg, action, field, value=nil)
    nick = msg.user.nick
    player = @db[:players].find(nick: nick)
    player.each do
      case action
        when "set"
          set_character(msg, player, field, value)
        when "get"
          get_character(msg, player, field)
        when "add"
          add_character(msg, player, field, value)
        else
          msg.reply "Sorry, that action is not avaliable. :("
      end
      return
    end
    msg.reply "#{nick} does not have a character yet."
    msg.reply "Use !new to get started."
  end

  def add_character(msg, player, field, value)
    player.each do |p|
      case field
        when "skill"
          add_character_skill msg, player, value
        else
          msg.reply "Sorry, that action is not available. :("
          return
      end
    end
  end

  # Set some character field
  def set_character(msg, player, field, value)
    player.each do |p|
      case field
        when /^name|backstory&/
          if p[field] != nil
            msg.reply "You already have a #{field}!"
            get_character msg player field
            return
          end
          p[field] = value
          msg.reply "Done!" if player.update_one p
        when :race
          set_character_race msg, player, value
        else
          msg.reply "Sorry, that action is not available. :("
          return
      end
    end
  end

  def set_character_race(msg, player, race)
    # Check that it is a valid race
    @db[:races].find({name: race}).each do
      # Update the player
      player.each do |p|
        p[:race] = race
        player.update_one p
      end
      msg.reply "Done!"
      return
    end
    # If this is not a valid race
    msg.reply "I'm sorry, than is not a valid race." if race
    msg.reply "Use: !player set race RACE"
    printallraces msg
  end

  def add_character_skill(msg, player, skill)
    # Check that the skill is valid
    @db[:skills].find({name: skill}).each do
      player.each do |p|
        # Check that the player has skill points to spend
        p[:skillPoints] ||= 0
        unless p[:skillPoints] > 0
          msg.reply "You don't have any skill points left!"
          return
        end
        # Initialize the skill if necessary
        p[:skills] ||= {}
        p[:skills][skill] ||= 0
        # Add a skill point for that skill
        p[:skills][skill] += 1
        p[:skillPoints] -= 1
        player.update_one p 
        msg.reply "Done!"
        return
      end
    end
    msg.reply "I'm sorry, that is not a valid skill. :("
  end

  # Get a character field
  def get_character(msg, player, field)
    player.each do |p|
      msg.reply "#{field}: #{p[field]}"
    end
  end

  # Create a new character
  def new_character(msg)
    nick = msg.user.nick
    @db[:players].find({ nick: nick }).each do
      msg.reply "#{nick} already has a character!"
      return
    end
    # Initialize the player from the template
    @db[:players].find({ nick: "template" }).each do |player|
      player["_id"] = nil  # Reset the id
      player[:nick] = nick # Set the players nick
      @db[:players].insert_one player # Add it to the database
      break
    end
    msg.reply "Created new character for #{nick}!"
    msg.reply "To give your character a name, use: !player set name NAME"
    msg.reply "To give your character a race, use: !player set race RACE"
    msg.reply "To add a backstory, use: !player set backstory BACKSTORY"
  end

  # Print a list of the existing functions
  def help (msg)
    msg.reply "!help, !roll, !races, !attrs, !skills, !new, !player"
  end

  # Connet to the database
  def dbconnect
    # Load up our yaml configuration
    config = YAML::load_file($configfile)
    # Make the database connection
    dbconnect = Mongo::Client.new(config[:db][:hosts], config[:db][:options])
    # Now we set our collections
    @db={}
    config[:co].each_key { |key| @db[key] = dbconnect[config[:co][key] }
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
    @db[:races].find().each do |race|
      attrs = race[:modifiers][:attributes]
      message = sprintf "%-9s", "#{race[:name]}:"
      attrs.each_key do |a|
        message += sprintf " %s %+i,", a.to_s.capitalize, attrs[a]
      end
      message[-1] = "\n"
      msg.reply message
      sleep 0.5
    end
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

  # Check an attribute
  def unabrevattr(name)
    # Check if this is abbreviated
    puts name
    return nil unless name.class == String
    full = @db[:attrs].find({short: name}) if name.length == 3
    full = @db[:attrs].find({name: name}) if name.length > 3
    full.each { |f| return f[:name] }
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
