class User
  include Mongoid::Document
  field :_id, type: String, default: ->{ name }
  field :name, type: String
  field :password_salt, type: String
  field :password_hash, type: String
  field :admin, type: Boolean
 
  attr_accessor :password
  before_save :encrypt_password
 
  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :name
  validates_uniqueness_of :name
  
  def self.authenticate(name, password)
    user = User.find name
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end
  
  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
end
