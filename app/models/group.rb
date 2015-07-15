class Group < Base

  PROPERTIES = [:id, :name, :password, :min_score, :max_score, :interval, :average_score, :exclude_score_after_weeks, :score_count]
  COLOR = "#06BF40".to_color

  attr_accessor *PROPERTIES

  def self.default
    Group.new(min_score: 0.0, max_score: 0.0, interval: 0.0, average_score: 0.0, exclude_score_after_weeks: 0, score_count: 0)
  end

  def self.storage_key
    "group"
  end

  def formatted_average_score
    '%.2f' % average_score.to_f
  end

end