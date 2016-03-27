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

  # Checks if the physattr is hidden
  def is_hidden?
    Physattr.where(name: self.name).first.hidden
  end

  def self.name_exists?(name)
    self.where(name: name).first
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
