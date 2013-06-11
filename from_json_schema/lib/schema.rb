require 'patch'
require 'yajl/json_gem'
require_relative 'delegate.rb'

class Schema < Thor

  desc "interpret", "Interpret a Schema File into Canonical Format"
  def interpret(schema_file)

    mocks = Delegate.new.interpret(schema_file, options)

    puts mocks.inspect

  end

  desc "generate", "Interpret the Schema File into a Canonical Format, and generate equivalent source files"
  method_option :namespace, :default => '', :aliases => '-n', :desc => "The Namespace to generate the Source Files in e.g. foo.bar.baz"
  method_option :root_folder, :default => '', :aliases => '-r', :desc => "The Root Folder to create the files in e.g. src"
  def generate(schema_file)

    delegate = Delegate.new

    folder_path = delegate.create_path(options[:namespace], options[:root_folder])

    mocks = delegate.interpret(schema_file, options)

    puts mocks.inspect

    files = delegate.generate(mocks, folder_path, options[:namespace], options)
    puts files.inspect

  end
end


