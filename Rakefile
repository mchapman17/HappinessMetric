# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bubble-wrap'
require 'formotion'
require 'bundler'

if ARGV.join(' ') =~ /spec/
  Bundler.require :default, :test
else
  Bundler.require
end

VERSION = '1.0'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'Happiness Metric'
  app.version = VERSION

  app.interface_orientations = [:portrait]

  app.redgreen_style = :progress

  # app.info_plist['API_HOST'] = YAML.load_file("config/config.yml")
end
