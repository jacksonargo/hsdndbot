class Advtype < Personality
  include Mongoid::Document
  include Mongoid::Timestamps

  embeds_many :typereqs

  def to_s
    "#{name}"
  end

  ## Checks if the player meets the requirements to add this adv type
  def meets_reqs?(player)
    typereqs.each do |req|
      return false unless req.player_meets? player
    end
    return true
  end
end
