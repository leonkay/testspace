require 'erb'

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

    @namespace = namespace
    @class_name = canonical_model.type_name.singularize.camel_case
    @required = []

    canonical_model.attributes.select do |attribute|
      !attribute.type.eql?("string") && !attribute.type.eql?("integer")
    end.each do |attribute|
      @required << "#{attribute.name.singularize.underscore}"
    end

    @canonical_model = canonical_model

    template = ERB.new File.new("#{File.dirname(__FILE__)}/../template/ruby.rb.erb").read
    request_body = template.result binding
    p file, request_body
  end

end