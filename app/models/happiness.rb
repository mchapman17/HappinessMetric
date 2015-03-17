class Happiness

  HAPPINESS_KEY = "happiness"
  PROPERTIES = [:user_score, :group_score]

  attr_accessor *PROPERTIES

  def initialize(properties = {})
    properties.each do |key, value|
      if PROPERTIES.include?(key.to_sym)
        self.send("#{key}=", value)
      end
    end
  end

  def initWithCoder(decoder)
    self.init
    PROPERTIES.each do |prop|
      saved_value = decoder.decodeObjectForKey(prop.to_s)
      self.send("#{prop}=", saved_value)
    end
    self
  end

  def encodeWithCoder(encoder)
    PROPERTIES.each do |prop|
      encoder.encodeObject(self.send(prop), forKey: prop.to_s)
    end
  end

  def save
    defaults = NSUserDefaults.standardUserDefaults
    defaults[HAPPINESS_KEY] = NSKeyedArchiver.archivedDataWithRootObject(self)
  end

  def self.load
    defaults = NSUserDefaults.standardUserDefaults
    data = defaults[HAPPINESS_KEY]
    NSKeyedUnarchiver.unarchiveObjectWithData(data) if data
  end

  def get_average_group_score
    AFMotion::JSON.get('http://localhost:3000/happiness/average_group_score/68db153d-dbd4-43d2-bc61-85057562fd83') do |result|
      if result.success?
        puts "-------------\n #{result.object["average_group_score"]}\n---------------"
        self.group_score = result.object["average_group_score"]
        puts "group: #{self.group_score}"
      elsif result.operation.response.statusCode.to_s =~ /40\d/
        App.alert("Group Score update failed.")
      elsif result.failure?
        App.alert(result.error.localizedDescription)
      end
    end
  end



end