class Classtype
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

class Basetype < Classtype
  embeds_many :typeattrs

  # Get the attribute buff for a basetype
  def self.attrBuff(typename, attrname)
    # Get the basetype object
    b = self.where(name: typename).first
    # Get the physattr object
    a = b.typeattrs.where(name: attrname).first
    # Return the buff value
    return a.value
  end
end
