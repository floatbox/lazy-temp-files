#!/usr/bin/env ruby
# encoding: utf-8


require 'tempfile'
puts Tempfile.public_instance_methods
puts '-'*10
puts Tempfile.new('').methods

