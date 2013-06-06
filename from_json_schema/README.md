Project Description
-----
This project provides an example on setting up a Thor application, distributing the logic into multiple files as opposed to a single
script.
Follows the example given in http://lostechies.com/derickbailey/2011/04/29/writing-a-thor-application/

This particular project is used to generate Source files from a given JSON Schema

Project Structure
-----
The following is a brief description of the structure of this project

    + lib : Contains ruby source files leveraged by the thor application
    |+ dto.rb
    |+ interpreter.rb
    |+ mocker.rb
    |+ parser.rb
    |+ patch.rb
    |+ schema.rb
    Gemfile : Contains required gems for this project. Used with the latest 'bundler' gem
    README.md : Readme for this project
    schema.thor : The Thor file that is leveraged by the 'thor' command line utility

Getting Started
-----

This application is developed on Ruby 1.9.3.

It is recommended that you start with a fresh gemset. In the example below, the gemset is 'from_json_schema' on Ruby 1.9.3

    rvm use --create 1.9.3@from_json_schema

This application use bundler to load gems

    gem install bundler

To Force a Clean Gemset e.g. rebuild your gemset from scratch

    rvm --force gemset empty from_json_schema
    gem update                                  # will ensure bundler and jruby gems are up to date
    bundle install

Configuration
-----

Usage
-----

Installation:

    gem update
    bundle install

Running the Script:

From the root directory (~/from_json_schema):

    thor schema:interpret {JSON Schema File Path}
    thor schema:generate {JSON Schema File Path}

Use 'thor list' to see what options are supported.


Enhancements
-----
- Support Java Generation
- Support RSPEC Generation
- Support V4 Json Schema
