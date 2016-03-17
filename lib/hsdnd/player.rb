class Player
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,        type: String
  field :nick,        type: String
  field :backstory,   type: String
  field :note,        type: String
  field :skillPoints, type: Integer
  field :classPoints, type: Integer
  field :attrPoints,  type: Integer
  field :featPoints,  type: Integer
  field :coin,        type: Float
  field :hp,          type: Float
  field :sp,          type: Float
  field :level_log,   type: Array
  field :race,        type: String
  field :baseType,    type: String

  embeds_many :plyrskills
  embeds_many :plyrattrs

  def self.new_player(nick)
    p = self.new
    p.nick = nick
    p.coin = 50
    p.skillPoints = 4
    p.hp = 1
    p.sp = 1
    p.plyrattrs = Plyrattr.new_list
    p.level_log = []
    p.level_log << "Created a character!"
    return p
  end

  # Returns the player's nick
  def saynick
    puts self.nick
  end

  # Returns the player's level
  def level
    self.level_log.length
  end

  # Returns true if the player has any hp
  def is_alive?
    return true if self.hp > 0
    return false
  end

  # If a player has that nick, return that player,
  # else return nil.
  def self.nick_exists?(nick)
    return Player.where(nick: nick).first
  end

  ## Set player base class
  # Returns nil if the class does not exist
  # Returns true if successful
  def setBase(base_name)
    base_name.capitalize!
    Basetype.where(name: base_name).each do
      self.baseType = base_name
      return true
    end
    return nil
  end

  ## Set player race
  # Returns nil if the race does not exist
  # Returns true if successful
  def setRace(race_name)
    race_name.capitalize!
    # Check that the race exists
    Race.where(name: race_name).each do
      self.race = race_name
      return true
    end
    # If the race didn't exist, return nil
    return nil
  end

  ## Add/increment a player skill
  # Returns nil if the skill does not exist
  # Returns the current value of the skill on success
  def addSkill(skill_name)
    skill_name.capitalize!
    # Check if the player already has the skill
    self.plyrskills.where(name: skill_name).each do |s|
      s.base_value += 1
      self.save
      return s.base_value
    end
    # Check if the skill exists at all
    Skill.where(name: skill_name).each do |skill|
      self.plyrskills << Plyrskill.clone(skill)
      self.save
      return 1
    end
    # Skills doesn't exist, so we return nil
    return nil
  end
end
