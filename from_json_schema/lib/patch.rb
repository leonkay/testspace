module MyStringExtensions

  def singularize

    rtn = self
    if self =~ /(.*)ses$/i
      rtn = $~.captures[0]

    elsif self =~ /(.*)s$/i
      rtn = $~.captures[0]

    elsif self =~ /(.*)dren/i
      rtn = "#{$~.captures[0]}d"
    end

    rtn = "#{rtn}s" if rtn =~ /statu|.*addres/i

    rtn
  end

  def camel_case
    return self if self !~ /_/ && self =~ /[A-Z]+.*/
    split('_').map{|e| e.capitalize}.join
  end

  def underscore
    if self.nil?
      self
    else
      self.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").downcase
    end
  end

  # destructive version
  def classname!(stopwords=%w{and or a an the of for by})
    self.gsub!(/\w+/) do |w|
      stopwords.map(&:downcase).include?(w.downcase!) ? "" : w.capitalize
    end.gsub!(/\s+/, '')
  end

  # duplicating version
  def classname(stopwords=%w{and or a an the of for by})
    dup.classname!(stopwords)
  end

  # destructive version
  def file_name!(stopwords=%w{and or a an the of for by})
    self.gsub!(/\w+/) do |w|
      stopwords.map(&:downcase).include?(w.downcase!) ? w : w.capitalize
    end.gsub!(/^\w/, '').downcase.gsub(/\s+/, '_')
  end

  # duplicating version
  def file_name(stopwords=%w{and or a an the of for by})
    dup.file_name!(stopwords)
  end

  def object?
    self.downcase == "object"
  end

  def integer?
    self.downcase  == "integer"
  end

  def long?
    self.downcase  == "number" || self.downcase  == "long"
  end

  def float?
    self.downcase  == "number" || self.downcase  == "float"
  end

  def boolean?
    self.downcase  == "boolean"
  end

  def string?
    self.downcase  == "string"
  end
end

String.send(:include, MyStringExtensions)

module ArrayExtensions
  def type
    temp = "string"
    self.each do |t|
      temp = t unless t.downcase != "null"
    end
    temp
  end

  def nullable?
    can_null = false

    self.each do |t|
      if !t.nil? && t.downcase == "null"
        can_null = true
      end
    end

    can_null
  end
end

Array.send(:include, ArrayExtensions)

module V3HashExtensions

  def name
    temp = self["name"]

    return nil if temp.nil?
    temp.gsub(/[.]/, '').classname
  end

  def type
    temp_type = self["type"]
    if temp_type.kind_of?(Array)
      type = temp_type.select {|t| t.downcase != "null"}[0]
    else
      type = temp_type
    end

    type
  end

  def readonly?
    attr = self["readonly"]
    !attr.nil? && attr
  end

  def required?
    attr = self["required"]
    !attr.nil? && attr
  end

  def nullable?
    temp_type = self["type"]
    can_null = false
    if !temp_type.nil? && temp_type.kind_of?(Array)
      temp_type.each do |t|
        if !t.nil? && t.downcase.eql?("null")
          can_null = true
        end
      end
    else
      can_null = temp_type.eql? "null"
    end
    can_null
  end

  def attributes
    properties = self["properties"]
    if properties.nil?
      properties = self[:properties]
    end

    properties
  end
end

