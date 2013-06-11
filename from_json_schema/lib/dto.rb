class ClassGenerator

  attr_accessor :tab_count, :tab_character

  def initialize
    @tab_count = 0
    @tab_character = "  "
  end

  def tab_space
    (1..@tab_count).inject("") do|rtn, count|
      rtn = "#{rtn}#@tab_character"
      rtn
    end
  end

  def increment_tab
    @tab_count += 1
  end

  def decrement_tab
    @tab_count -= 1
    if @tab_count < 0
      @tab_count = 0
    end
  end

  # print to console and file
  def p(file, string)
    puts string
    file.write(string)
  end

  def tab(file, string)
    p(file, "#{tab_space}#{string}\n")
  end

  def generate(canonical_models, namespace, root_path)
    canonical_models.inject([]) do |file_names, canonical_model|
      @tab_count = 0
      file_path = "#{root_path}/#{canonical_model.type_name.singularize.underscore}.#{extension}"

      begin
        puts "Creating File #{file_path}"
        file = File.open(file_path, "w")

        write(file, namespace, canonical_model)

      rescue => e

        puts "An Exception occurred while attempting to write the class file #{file_path} : #{e}"
      end

      file_names << file_path
      file_names
    end
  end


  def write(file, namespace, canonical_model)
    #override me
  end

  def extension
    #override me
  end
end


class RubyClassGenerator < ClassGenerator

  def extension
    "rb"
  end

  def write(file, namespace, canonical_model)
    class_name = canonical_model.type_name.singularize.camel_case

    p file, "require 'set'\n"

    canonical_model.attributes.select do |attribute|
      !attribute.type.eql?("string") && !attribute.type.eql?("integer")
    end.each do |attribute|
      p file, "require_relative '#{attribute.name.singularize.underscore}'\n"
    end

    p file, "\n\n"
    p file, "class #{class_name}\n"

    increment_tab

    canonical_model.attributes.each do |attribute|
      tab file, "attr_accessor :#{attribute.name}"
    end

    p file, "\n\n"

    tab file, "TYPE_HASH = {}"

    canonical_model.attributes.each do |attribute|
      tab file, "TYPE_HASH[:#{attribute.name}] = #{attribute.type.camel_case}"
    end

    p file, "\n\n"

    tab file, "SUPPORTS_NULL = Set.new"

    canonical_model.attributes.select {|att| att.nullable? }.each do |attribute|
      tab file, "SUPPORTS_NULL.add(:#{attribute.name})"
    end

    p file, "\n\n"
    tab file, "IS_ARRAY = Set.new"

    canonical_model.attributes.select {|att| att.array? }.each do |attribute|
      tab file, "IS_ARRAY.add(:#{attribute.name})"
    end

    p file, "\n\n"

    tab file, "def initialize(json={})"
    increment_tab
    canonical_model.attributes.each do |attribute|
      tab file, "@#{attribute.name} = args[:#{attribute.name}]"
    end

    decrement_tab
    tab file, "end"

    p file, "\n\n"
    tab file, "class << self"
    increment_tab
    tab file, "def construct(node)"
    increment_tab

    tab file, "instance = #{class_name}.new"

    tab file, "node.each do |key, value|"
    increment_tab
    tab file, "symbolized_setter = \"\#{key}=\".to_sym"
    tab file, "symbolized_key = \"\#{key}\".to_sym"
    tab file, "if instance.respond_to? symbolized_setter"
    increment_tab
    tab file, "raise \"\#{key} does not support a null value\" if value.nil? && !SUPPORTS_NULL.include?(symbolized_key)"
    tab file, "raise \"\#{key} should be an array \" if !value.nil? && IS_ARRAY.include?(symbolized_key) && !value.is_a?(Array)"

    tab file, "value_type = TYPE_HASH[symbolized_key]"

    tab file, "if !value.nil? && value.is_a?(Hash)"
    increment_tab
    tab file, "attribute = value_type.construct(value)"
    decrement_tab
    tab file, "elsif !value.nil? && value.is_a?(Array)"
    increment_tab
    tab file, "attribute = []"
    tab file, "value.each do |element|"
    increment_tab
    tab file, "attribute << value_type.construct(element)"
    decrement_tab
    tab file, "end"
    decrement_tab
    tab file, "else"
    increment_tab
    tab file, "raise \"#{class_name}.\#{key} contains an invalid attribute type, should be a \#{value_type}\" if !value.nil? && !value.is_a?(value_type)"
    tab file, "attribute = value"
    decrement_tab
    tab file, "end"

    tab file, "instance.send(symbolized_setter, attribute)"

    decrement_tab
    tab file, "else"
    increment_tab

    tab file, "raise \"\#{key} is not defined on class #{class_name}\""

    decrement_tab
    tab file, "end"

    decrement_tab
    tab file, "end"

    decrement_tab
    tab file, "end"
    decrement_tab
    tab file, "end"
    p file, "end"
  end
end