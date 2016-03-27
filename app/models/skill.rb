class Skill
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name,          type: String
  field :summary,       type: String
  field :examples,      type: Array
  field :related_pattr, type: String
  field :hidden,        type: Boolean

  # Checks if the physattr is hidden
  def is_hidden?
    Skill.where(name: self.name).first.hidden
  end

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
