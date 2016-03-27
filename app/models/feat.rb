class Feat
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,        type: String
  field :last_used,   type: Date
  field :perk,        type: String, default: "None"
  field :personality, type: String, default: "None"
  field :activation,  type: String, default: "Passive"

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

  ## Return who we belong to
  def belongs_to_player
    key = self.reflect_on_association(:player).inverse
    Player.where({ key => self.attributes }).first
  end

  def campaign
    Campaign.where(name: belongs_to_player.campaign).first
  end

  ## Checks if the feat can be activated
  def can_activate?(activation)
    return true if /[Pp]assive/ =~ activation
    return true unless last_used
    
    case activiation
    when "Daily"
      target = last_used.next_day 
    when "Weekly"
      target = last_used.next_week
    when "Biweekly"
      target = last_used.next_week.next_week
    when "Monthly"
      target = last_used.next_month
    when "Yearly"
      target = last_used.next_year
    else
      return false
    end

    target < campaign.date
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
