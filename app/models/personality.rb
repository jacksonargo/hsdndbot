class Personality
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,       type: String
  field :summary,    type: String
  field :usualRoles, type: Array

  def to_s
    "Name: #{self.name}\nSummary: #{self.summary}\nUsual Roles: #{self.usualRoles.join(', ')}."
  end

end
