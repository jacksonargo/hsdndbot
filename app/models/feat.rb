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
end
