class Group < Base

  PROPERTIES = [:id, :name, :password, :min_score, :max_score, :interval, :average_score, :user_count]
  COLOR = "#06BF40".to_color

  attr_accessor *PROPERTIES

  def self.default
    Group.new(id: "991d752a-62c1-4604-8531-cb3ee3fa9e8e", name: "Hooroo", password: "password",
              min_score: 0.0, max_score: 5.0, interval: 0.1, average_score: 0.0, user_count: 0)
  end

  def self.storage_key
    "group"
  end

end