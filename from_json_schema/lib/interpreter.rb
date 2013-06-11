require "mocker"

class Interpreter

  def translate
    # Override me!
  end
end

class V3Interpreter < Interpreter

  attr_reader :mocked_classes

  def initialize
    Hash.send(:include, V3HashExtensions)
    @mocked_classes = []
  end

  def interpret_array(name, properties)
    type_node = properties.type
    can_null = properties.nullable?
    readonly = properties.readonly?
    description = properties[:description.to_s]
    required = properties.required?

    type = type_node[0] # should be an array
    child_type = properties.name
    if child_type.nil?
      child_type = name.singularize.camel_case
    end
    # parse child elements here to determine child_type

    translate_child_object(child_type, properties)

    options = {:is_array => true, :is_null => can_null, :is_readonly => readonly, :description => description, :required => required}


    Mock::Attribute.new(name, child_type, options)
  end

  def interpret_object(name, properties)
    type_node = properties.type
    description = properties[:description.to_s]

    mocked = Mock::Stub.new(name)

    properties.each do |attribute_name, attribute_properties|
      mocked.attributes << interpret_attribute(attribute_name, attribute_properties)
    end

    @mocked_classes << mocked
    mocked
  end

  def interpret_attribute(name, properties)

    type = properties.type

    if type.eql? "object"
      obj = interpret_object(name.singularize, properties.attributes)

      can_null = properties.nullable?
      readonly = properties.readonly?
      description = properties[:description.to_s]
      required = properties.required?
      options = {:is_null => can_null, :is_readonly => readonly, :description => description, :required => required}

      rtn = Mock::Attribute.new(name, obj.type_name, options)
    elsif type.eql? "array"
      rtn = interpret_array(name, properties)
    else
      can_null = properties.nullable?
      readonly = properties.readonly?
      description = properties[:description.to_s]
      required = properties.required?
      options = {:is_null => can_null, :is_readonly => readonly, :description => description, :required => required}

      rtn = Mock::Attribute.new(name, properties.type, options)
    end
    rtn
  end

  def translate_child_object(name, schema)
    interpret_object(name, schema["items"].attributes)
  end

  # should only be called at the root level
  def translate(schema,default_name="default",is_root=true)
    name = schema.name
    type = schema.type

    if name.nil?
      name = default_name
    end

    if type == "object"
      interpret_object(name.singularize, schema.attributes)
    elsif type == "array"
      name = "#{name}Array"
      interpret_array(name, schema.attributes)
    else
      if is_root
        # Root Type should be either an Array or an Object/Class
        raise "Root Object of JSON Schema must be an 'object' or an 'array'"
      else
        interpret_attribute(name, schema.attributes)
      end

    end
    @mocked_classes
  end

  private :interpret_attribute, :interpret_array, :interpret_object
end