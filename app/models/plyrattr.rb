class Plyrattr < Physattr
  embedded_in :player
  field :base_value, type: Integer

  # Clone from a physattr
  def self.clone (a)
    n = self.new
    n.name = a.name
    n.base_value = 6
    return n
  end

  # Create a new list of all physattrs
  def self.new_list
    list = []
    Physattr.where({}).each do |a|
      list << self.clone(a)
    end
    list
  end

  # Increment the base value
  def up(x=1)
    self.base_value += x
    self.save
    self.base_value
  end

  # Find out who we belong to
  def belongs_to_player
    Player.where({ plyrattrs: self.attributes }).first
  end

  # Takes a player and calculates the total buff for an attribute
  def modifiers(player=nil)
    player ||= belongs_to_player
    x = 0
    # From the base class
    if player.baseType
      x += Basetype.attrBuff player.baseType, self.name
    end
    # From the race
    if player.race
      x += Race.attrBuff player.race, self.name
    end
    return x
  end

  # Total value of the attr
  def total (player=nil, mods=nil)
    player ||= belongs_to_player
    mods ||= modifiers(player)
    base_value + mods
  end

  # Calculate the skill buff for the attr
  def skill_mod(player=nil)
    player ||= belongs_to_player
    t = total
    t -= 10
    t > 0 ? (t/2) : t
  end
end
