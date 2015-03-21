class Base

  def initialize(properties = {})
    properties.each do |key, value|
      if self.class::PROPERTIES.include?(key.to_sym)
        self.send("#{key}=", value)
      end
    end
  end

  def initWithCoder(decoder)
    self.init
    self.class::PROPERTIES.each do |prop|
      saved_value = decoder.decodeObjectForKey(prop.to_s)
      self.send("#{prop}=", saved_value)
    end
    self
  end

  def encodeWithCoder(encoder)
    self.class::PROPERTIES.each do |prop|
      encoder.encodeObject(self.send(prop), forKey: prop.to_s)
    end
  end

  def save
    defaults = NSUserDefaults.standardUserDefaults
    defaults[@storage_key] = NSKeyedArchiver.archivedDataWithRootObject(self)
  end

  def self.load
    defaults = NSUserDefaults.standardUserDefaults
    data = defaults[storage_key]
    puts "storage key: #{storage_key}"
    puts "data: #{data}"
    NSKeyedUnarchiver.unarchiveObjectWithData(data) if data
  end

end