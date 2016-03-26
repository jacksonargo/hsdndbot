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

  validates :name, presence: true
  validates :backstory, presence: true
  validates :race, presence: true
  validates :baseType, presence: true

  def self.new_player(nick)
    p = self.new
    p.nick = nick
    p.coin = 50
    p.skillPoints = 4
    p.hp = 1
    p.sp = 1
    p.plyrattrs = Plyrattr.new_list   # New list of attrs
    p.plyrskills = Plyrskill.new_list # New list of skills
    p.level_log = []
    p.level_log << "Created a character!"
    return p
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
    if Basetype.where(name: base_name).exists?
      self.baseType = base_name
      return true
    end
    return nil
  end

  # Set player race
  # Returns nil if the race does not exist
  # Returns true if successful
  def setRace(race_name)
    race_name.capitalize!
    # Check that the race exists
    if Race.where(name: race_name).exists?
      self.race = race_name
      return true
    end
    # If the race didn't exist, return nil
    return nil
  end

  # Check for a valid skill name
  # This will also automatically add the skill to the player
  # if the skill exists, but the player does not have it.
  # Returns the skill object if it exists, else returns nil.
  def skill_exists?(skill_name)
    skill_name.capitalize!

    # Check if the player has that skill
    ps = self.plyrskills.where(name: skill_name).first
    # We are done if the the player has that skill
    return ps if ps != nil

    # Now we need to check if that skill actually exists.
    skill = Skill.name_exists? skill_name
    # If the skill does not exist at all, we're done.
    return nil unless skill != nil

    # Since the skill exists, we need to add it to the player.
    new = Plyrskill.clone skill
    self.plyrskills << new
    self.save
    return new
  end

  # Increment a player skill
  # Returns nil if the skill does not exist
  # Returns the current value of the skill on success
  def skillup(skill_name, x=1)
    skill_name.capitalize!
    s = self.plyrskills.where(name: skill_name).first
    return nil unless s
    s.up x
  end
end
