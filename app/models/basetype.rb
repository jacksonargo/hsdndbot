class Basetype < Personality
  embeds_many :typeattrs
  accepts_nested_attributes_for :typeattrs

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

  # Check for a valid physattr name
  # Automatically add the attr if it does not exists
  # Returns the raceattr object if it exists
  def typeattr_exists?(tattr_name)
    tattr_name.capitalize!

    tattr = self.typeattrs.where(name: tattr_name).first

    # We are done if the tattr exists
    return tattr if tattr != nil

    # Now check if the name actually exists
    pattr = Physattr.name_exists? tattr_name
    # If the pattr doesn't exist, we are done
    return nil unless pattr != nil

    # Since it does exist, we add it to the list
    new = Raceattr.new
    new.name = pattr.name
    new.value = 0
    self.typeattrs << new
    return new
  end

  ## In order to make things a little more general,
  ## we can refer to the raceattr as physattr

  def physattr_exists?(rattr_name)
    typeattr_exists?(rattr_name)
  end

  def physattr
    self.typeattr
  end
end
