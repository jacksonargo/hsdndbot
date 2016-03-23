class Article
  include Mongoid::Document
  field :title, type: String
  field :text, type: String
  validates :title, presence: true, length: { minimum: 5 }
  embeds_many :comments
end
