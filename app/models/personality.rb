class Personality
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,       type: String
  field :baseClass,  type: Boolean
  field :summary,    type: String
  field :usualRoles, type: Array

  def to_s
    "Name: #{self.name}\nSummary: #{self.summary}\nUsual Roles: #{self.usualRoles.join(', ')}."
  end

end

class Basetype < Personality
  embeds_many :typeattrs

  # Return a string form of the race
  def to_s
    # Start with the name
    string = sprintf "%-9s", "#{self.name}:"
    # Print the attr mods
    self.typeattrs.each do |a|
      string += sprintf " %s %+i,", a.short, a.value
    end
    return string.chomp(",")
  end

  def attrBuff(attrname)
    a = self.typeattrs.where(name: attrname).first
    a ? a.value : 0
  end

  def self.attrBuff(typename, attrname)
    x = self.where(name: typename).first
    x.attrBuff(attrname)
  end
end
