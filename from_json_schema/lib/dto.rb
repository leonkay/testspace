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

  def generate(canonical_models, root_path)
    canonical_models.inject([]) do |file_names, canonical_model|
      @tab_count = 0
      file_path = "#{root_path}/#{canonical_model.type_name.underscore}.#{self.extension}"

      begin
        puts "Creating File #{file_path}"
        file = File.open(file_path, "w")

        write(file, canonical_model)

      rescue => e

        puts "An Exception occurred while attempting to write the class file #{file_path} : #{e}"
      end

      file_names << file_path
      file_names
    end
  end


  def write(file, canonical_model)
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

  def write(file, canonical_model)
    class_name = canonical_model.type_name.camel_case


    p file, "class #{class_name}\n"

    increment_tab

    canonical_model.attributes.each do |attribute|
      p file, "#{tab_space}attr_accessor :#{attribute.name}\n"
    end

    p file, "\n\n"
    p file, "#{tab_space}def initialize(args={})\n"
    increment_tab
    canonical_model.attributes.each do |attribute|
      p file, "#{tab_space}@#{attribute.name} = args[:#{attribute.name}]\n"
    end
    decrement_tab
    p file, "#{tab_space}end\n"
    p file, "end"
  end
end