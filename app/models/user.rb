class User < ActiveRecord::Base
  include Uuidable
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, :presence => true, :uniqueness => true, :format => EMAIL_REGEX
  validates_length_of :password, :in => 6..50, :if => proc { self.password_confirmation.present? }
  before_save :encrypt_password
  after_save :clear_password

  def encrypt_password
    if password.present?
      if password == password_confirmation
        self.salt = BCrypt::Engine.generate_salt
        self.encrypted_password = BCrypt::Engine.hash_secret(password, salt)
      else
        raise "Password is not valid or does not match confirmation"
      end
    end
  end

  def clear_password
    update_attributes(password: nil, password_confirmation: nil)
  end


  def persistent
    persisted?
  end

  def match_password(login_password="")
    encrypted_password == BCrypt::Engine.hash_secret(login_password, salt)
  end
end
