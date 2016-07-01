class Plyrfeat << Feat
  embedded_in :player
  field :last_used,   type: Date
  field :uses,        type: Integer, default: 0
end
