#!/usr/bin/env ruby
# encoding: utf-8

require 'tempfile'

class Gladiator
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def say_hello
    puts "hi cesar"
    yield(name) if block_given?
    puts "go to deth"
  end
end

spartak = Gladiator.new("Spartak")
spartak.say_hello do |gladiator_name|
  puts "Title"
  puts "I, #{gladiator_name}, say:"
end


say_hello = lambda do
  word = "Привет!"
  puts word
end

def variable(&block)
  count = 0
  files = Array.new(block.arity) do |x|
    x = Tempfile.new('foo', '~/lab/printio/')
  end
  yield *files
  files.each { |x| x.close  }
end


variable do |file|
  puts file.inspect
end
