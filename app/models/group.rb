class Group < Base

  PROPERTIES = [:id, :name, :score]

  attr_accessor *PROPERTIES

  def self.storage_key
    "group"
  end

end