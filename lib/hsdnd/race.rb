class Race
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  embeds_many :raceattrs

  # Return the modifier for a particular attr
  def attrBuff(attrname)
    a = self.raceattrs.where(name: attrname).first
    a ? a.value : 0
  end

  def self.attrBuff(typename, attrname)
    x = self.where(name: typename).first
    x.attrBuff(attrname)
  end

  # Return a string form of the race
  def to_s
    # Start with the name
    string = sprintf "%-9s", "#{self.name}:"
    # Print the attr mods
    self.raceattrs.each do |a|
      string += sprintf " %s %+i,", a.short, a.value
    end
    return string.chomp(",")
  end
end
