class Race
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  validates :name, presence: true

  embeds_many :raceattrs
  accepts_nested_attributes_for :raceattrs

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
      string += sprintf " %s %+i,", a.short, a.value if a.value != 0
    end
    return string.chomp(",")
  end

  # Check for a valid physattr name
  # Automatically add the raceattr if it does not exists
  # Returns the raceattr object if it exists
  def raceattr_exists?(rattr_name)
    rattr_name.capitalize!

    rattr = self.raceattrs.where(name: rattr_name).first

    # We are done if the rattr exists
    return rattr if rattr != nil

    # Now check if the name actually exists
    pattr = Physattr.name_exists? rattr_name
    # If the pattr doesn't exist, we are done
    return nil unless pattr != nil

    # Since it does exist, we add it to the list
    new = Raceattr.new
    new.name = pattr.name
    new.value = 0
    self.raceattrs << new
    self.save
    return new
  end

  ## In order to make things a little more general,
  ## we can refer to the raceattr as physattr

  def physattr_exists?(rattr_name)
    raceattr_exists?(rattr_name)
  end

  def physattr
    self.raceattr
  end
end
