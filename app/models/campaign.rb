class Campaign
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,    type: String
  field :summary, type: String
  field :period,  type: Integer, default: 1
  field :date,    type: Date,    default: Time.now.to_date

  def players
    Player.where(campaign: name)
  end

end
