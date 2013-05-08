Project Description
-----

This is a sample application of using the active.com api to sync their data with a Google Calendar.

Project Structure
-----
The following is a brief description of the structure of this project

    + app : Contains Application Code
    |+ active_calendar_sync.rb : Contains the main application code for syncing active.com data
    Gemfile : Contains required gems for this project. Used with the latest 'bundler' gem
    README.md : Readme for this project

Getting Started
-----

This application should be able to run on stock ruby, but the code is developed using JRuby.

It is recommended that you start with a fresh gemset. In the example below, the gemset is 'runtown' on jruby 1.7.2.

    rvm use --create jruby-1.7.2@runtown

This application use bundler to load gems

    gem install bundler

To Force a Clean Gemset e.g. rebuild your gemset from scratch

    rvm --force gemset empty runtown
    gem update                                  # will ensure bundler and jruby gems are up to date
    bundle install

Configuration
-----
In active_calendar_sync.rb, there are multiple global variables which can be set to configure the application before running

    ACTIVE_API_KEY: This is your Mashery Active.com api key
    KEY_WORDS: Change this Value to Search on a specific type of event
    EVENT_TYPE: Takes priority over the variable 'KEY_WORDS'. This is the category of event data you are trying to retrieve from Active
        .com. E.G Running, Biking, etc
    GOOGLE_USER: Your google Email Address
    GOOGLE_PASS: Your Google Password
    CALENDAR_NAME: The Google Calendar to Sync active.com data with. TODO: This needs to be updated to work. Currently only works with
        default calendar

Usage
-----

Installation:

    gem update
    bundle install

Running the Script:

From the app directory:
    rvm use jruby-1.7.2@runtown
    ruby active_calendar_sync.rb


Enhancements
-----
This application currently only adds data to your calendar. Planned enhancements are
- Sync Event data with Calendar. Currently, if an event already exists, it will still add it to the calendar.
- Use the official Google API Gem to do Calendar Manipulation




