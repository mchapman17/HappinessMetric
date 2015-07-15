class User < Base

  PROPERTIES = [:id]
  COLOR = "#27D3E7".to_color

  attr_accessor *PROPERTIES

  def self.storage_key
    "user"
  end

end