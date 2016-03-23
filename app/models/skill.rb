class Skill
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name,        type: String
  field :summary,     type: String
  field :examples,    type: Array
  field :related_pattr, type: String

  def physattr
    Physattr.where(name: @related_pattr).first
  end

  def to_s
    "#{self.name} (#{self.related_pattr[0..2]}): #{self.summary}"
  end

  def self.name_exists?(name)
    Skill.where(name: name).first
  end
end

class Plyrskill < Skill
  field :base_value, type: Integer
  embedded_in :player

  def self.clone (skill)
    s = Plyrskill.new
    s.name = skill.name
    s.base_value = 0
    return s
  end

  def belongs_to_player
    key = self.reflect_on_association(:player).inverse
    Player.where({ key => self.attributes }).first
  end

  # Increment the skill value
  def up(x=1)
    self.base_value += x
    self.save
    self.base_value
  end

  def plyrattr(player=nil)
    player ||= belongs_to_player
    # Get the skill's related pattr
    # We have to look up the original skill definition
    pattr_name = Skill.where(name: self.name).first.related_pattr
    # Get the players plyrattr object
    player.plyrattrs.where(name: pattr_name).first
  end

  # Get the total value of the skill
  # Sum of the base value and the modifier from the skills related physattr
  def total
    player = belongs_to_player
    base_value + plyrattr.skill_mod(player)
  end

  # Roll 20 for this skill
  def roll(n=20)
    total + rand(n)
  end

  # Create a new list of all plyrskills
  def self.new_list
    list = []
    Skill.where({}).each do |a|
      list << self.clone(a)
    end
    list
  end
end
