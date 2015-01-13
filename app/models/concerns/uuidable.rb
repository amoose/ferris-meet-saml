module Uuidable
  extend ActiveSupport::Concern


  def initialize(attributes = {})
    super
    generate_token
  end  

  protected

  def generate_token
    self.uuid = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless self.class.exists?(uuid: random_token)
    end
  end
end