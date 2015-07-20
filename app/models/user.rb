class User < Base

  PROPERTIES = [:id]
  COLOR = "#27D3E7".to_color

  attr_accessor *PROPERTIES

  def self.storage_key
    "user"
  end

  def self.default
    user = self.new(id: BubbleWrap.create_uuid, score: 0.0)
    user.save
    user
  end

end