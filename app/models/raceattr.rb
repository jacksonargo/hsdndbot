class Raceattr < Physattr
  field :value, type: Integer
  validates :value, numericality: { only_integer: true }
  embedded_in :race
end
