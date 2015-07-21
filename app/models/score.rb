class Score < Base

  PROPERTIES = [:id, :score]

  attr_accessor *PROPERTIES

  def self.default
    Score.new(id: nil, score: 0.0)
  end

  def self.storage_key
    "score"
  end

  def formatted_score
    '%.1f' % score.to_f
  end

  def reset
    self.id = nil
    self.score = 0.0
  end

end