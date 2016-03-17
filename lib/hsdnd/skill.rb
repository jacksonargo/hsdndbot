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
  def self.get_plyrattr(player, skill_name)
    # Get the skill's related pattr
    pattr_name = self.where(name: skill_name).first.related_pattr
    # Get the players plyrattr object
    player.plyrattrs.where(name: pattr_name).first
  end
end

class Plyrskill < Skill
  field :base_value, type: Integer
  embedded_in :player
  def self.clone (skill)
    s = Plyrskill.new
    s.name = skill.name
    s.base_value = 1
    return s
  end

  # Get the total value of the skill
  def self.total(player, skill_name)
    # Get the current skill level
    x = self.has?(player, skill_name)
    if x
      base_value = x.base_value
    else
      base_value = 0
    end
    # Get the attr skillbuff
    plyrattr = Skill.get_plyrattr(player, skill_name)
    base_value + plyrattr.skillBuff(player)
  end

  def self.has?(player, skill_name)
    return player.plyrskills.where(name: skill_name).first
  end
end
