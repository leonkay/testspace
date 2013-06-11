require 'dto'
require 'interpreter'

class Delegate

  def interpret(schema_file, options)
    file = File.open(schema_file, "r")
    schema_content = file.read
    file.close

    # todo: detect ruby type and use appropriate gem to parse json
    parser = Yajl::Parser.new
    schema = parser.parse(schema_content)

    default_name = File.basename(schema_file).gsub(/[.].*/, '').camel_case

    # todo: Use options to determine which Interpreter to use for parsing the json schema
    interpreter = V3Interpreter.new
    interpreter.translate(schema, default_name)
  end

  def generate(mocks, folder_path, namespace, options)
    #todo: Use Options to Determine which Generator to Use
    RubyClassGenerator.new.generate(mocks, namespace, folder_path)
  end

  # Creates the folder structure for the specified namespace, in the provided root director
  def create_path(namespace, root="")

    if root.strip!.eql? ""
      root = Dir.pwd
    else
      root = "#{Dir.pwd}/#{root}"
    end

    begin
      Dir::mkdir root
    rescue
      # ignore error
    end
    puts "Creating Namespace #{namespace} in #{root}"
    folders = namespace.split('.').inject(root) do |path, fragment|
      path = "#{path}/#{fragment}"
      begin
        puts "-- Creating Directory #{path}"
        Dir::mkdir path
      rescue
        puts "-- The Directory #{path} already exists"
      end

      path
    end
    puts "Folder Path : #{folders}"
    folders
  end
end