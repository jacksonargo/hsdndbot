class Player
  include Mongoid::Document
  include Mongoid::Timestamps

  field :_id, type: String, default: ->{ nick }

  field :name,        type: String
  field :nick,        type: String
  field :backstory,   type: String
  field :note,        type: String
  field :race,        type: String
  field :baseType,    type: String
  field :campaign,    type: String,  default: "High School DnD"
  field :level_log,   type: Array,   default: []
  field :skillPoints, type: Integer, default: 0
  field :classPoints, type: Integer, default: 0
  field :attrPoints,  type: Integer, default: 0
  field :featPoints,  type: Integer, default: 0
  field :coin,        type: Float,   default: 0
  field :hp,          type: Float,   default: 0
  field :sp,          type: Float,   default: 0
  field :crimes_committed, type: Integer, default: 0
  field :uniq_drugs_used, type: Integer, default: 0
  field :em_relationship_checks_success, type: Integer, default: 0
  field :ph_relationship_checks_success, type: Integer, default: 0
  field :rumors, type: Integer, default: 0
  field :life_revelation, type: Boolean, default: false

  embeds_many :plyrskills
  embeds_many :plyrattrs
  embeds_many :plyrfeats

  accepts_nested_attributes_for :plyrskills
  accepts_nested_attributes_for :plyrattrs

  def self.new_player(nick)
    p = self.new
    p.nick = nick
    p.coin = 50
    p.skillPoints = 4
    p.hp = 1
    p.sp = 1
    p.plyrattrs = Plyrattr.new_list   # New list of attrs
    p.plyrattr_exists?("Any").base_value = 0
    p.plyrskills = Plyrskill.new_list # New list of skills
    p.level_log = []
    p.level_log << "Created a character!"
    return p
  end

  # Guesses what the name belongs to, and tries to get the
  # base value
  def base_value(name, collection)
    name = Physattr.long_name name if collection == :plyrattrs
    send(collection).where(name: name).first.base_value
  end

  # Returns the player's level
  def level
    self.level_log.length
  end

  # Returns the players max hp
  def max_hp
    level + base_value(:str, :plyrattrs) + 2 * base_value(:con, :plyrattrs)
  end

  # Returns the players max sp
  def max_sp
    level + base_value(:wis, :plyrattrs) + base_value(:con, :plyrattrs) + 5
  end

  def percent_sp
    sp / max_sp * 100
  end

  def percent_hp
    hp / max_hp * 100
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
    new.base_value = 0
    self.plyrskills << new
    return new
  end

  # Increment a player skill
  # Returns nil if the skill does not exist
  # Returns the current value of the skill on success
  def skillup(skill_name, x=1)
    s = self.plyrskills.where(name: skill_name).first
    return nil unless s
    s.up x
  end

  # Check for a valid physattr name
  # Automatically add the plyrattr if it does not exists
  # Returns the plyrattr object if it exists
  def plyrattr_exists?(rattr_name)
    rattr = self.plyrattrs.where(name: rattr_name).first

    # We are done if the rattr exists
    return rattr if rattr != nil

    # Now check if the name actually exists
    pattr = Physattr.name_exists? rattr_name
    # If the pattr doesn't exist, we are done
    return nil unless pattr != nil

    # Since it does exist, we add it to the list
    new = Plyrattr.new
    new.name = pattr.name
    new.base_value = 0
    self.plyrattrs << new
    return new
  end

  ## In order to make things a little more general,
  ## we can refer to the plyrattr as physattr

  def physattr_exists?(rattr_name)
    plyrattr_exists?(rattr_name)
  end

  def physattr
    self.plyrattr
  end


end
