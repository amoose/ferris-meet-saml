class User < ActiveRecord::Base
  include Uuidable
  
  def persistent
    persisted?
  end
end
