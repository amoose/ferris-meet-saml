class User < ActiveRecord::Base
  def persistent
    persisted?
  end
end
