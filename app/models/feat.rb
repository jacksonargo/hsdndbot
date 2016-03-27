class Feat
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :perk, type: String
  field :type, type: String
  field :uses, type: String

  embeds_many :featattrs
  accepts_nested_attributes_for :featattrs

  def self.valid_activations
    [
      "Passive",
      "Daily",
      "Weekly",
      "Biweekly",
      "Once a Month",
    ]
  end

  # Check for a valid physattr name
  # Automatically add the raceattr if it does not exists
  # Returns the raceattr object if it exists
  def featattr_exists?(fattr_name)
    fattr_name.capitalize!

    fattr = self.featattrs.where(name: fattr_name).first

    # We are done if the fattr exists
    return fattr if fattr != nil

    # Now check if the name actually exists
    pattr = Physattr.name_exists? fattr_name
    # If the pattr doesn't exist, we are done
    return nil unless pattr != nil

    # Since it does exist, we add it to the list
    new = Featattr.new
    new.name = pattr.name
    new.value = 0
    self.featattrs << new
    return new
  end


  def physattr_exists?(rattr_name)
    featattr_exists?(rattr_name)
  end

end
