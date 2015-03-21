class User < Base

  PROPERTIES = [:id, :score]

  attr_accessor *PROPERTIES

  def self.storage_key
    "user"
  end

end