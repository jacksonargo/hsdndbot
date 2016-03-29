class Advtype < Personality
  include Mongoid::Document
  include Mongoid::Timestamps

  embeds_many :typereqs

  ## Checks if the player meets the requirements to add this adv type
  def meets_reqs?(player)
    meets = true
    typereqs.each do |req|
      meets = false unless req.player_meets? player
    end
    meets
  end
end
