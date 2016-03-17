class Physattr
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name,     type: String
  field :summary,  type: String
  field :hidden,   type: Boolean

  def short
    self.name[0..2]
  end

  def to_s
    "(#{self.short}) #{self.name}"
  end

  # Match the full name if given an abbreviation
  def self.long_name (x)
    x = x.to_s # Make sure x is a string
    # Loop through the attrs until we find a match
    match = nil
    self.where({}).each do |b| 
      if b.name.downcase.include? x.downcase
        match = b.name
        break
      end
    end
    return match
  end
end

class Modattr < Physattr
  field :value, type: Integer
end

class Raceattr < Modattr
  embedded_in :race
end

class Typeattr < Modattr
  embedded_in :basetype
end

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
  def gain(x=1)
    @base_value += 1
  end

  # Takes a player and calculates the total buff for an attribute
  def modifiers (player)
    x = 0
    # From the base class
    if player.baseType
      x += Basetype.attrBuff player.baseType, @name
    end
    # From the race
    if player.race
      x += Race.attrBuff player.race, @name
    end
    return x
  end

  # Total value of the attr
  def total (player, mods=nil)
    mods ||= modifiers(player)
    base_value + mods
  end

  # Calculate the skill buff for the attr
  def skillBuff(player, t=nil)
    t ||= total(player)
    t -= 10
    t > 0 ? (t/2) : t
  end
end
