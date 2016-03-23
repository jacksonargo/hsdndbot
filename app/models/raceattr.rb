class Raceattr < Physattr
  field :value, type: Integer
  embedded_in :race
end
