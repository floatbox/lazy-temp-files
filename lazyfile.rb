#!/usr/bin/env ruby

require 'tempfile'

class Lazyfile
  module Helper

    def with_lazyfiles(&block)
      files = Array.new(block.arity) do |file|
        file = Lazyfile.new('printio', '~/lab/printio/')
      end
      block_params = files.size == 1 ? files[0] : files
      yield block_params if block_given?
      files.each { |file| file.close  }
    end

  end

  def initialize(basename, *rest)
    @basename = basename
    @rest = rest
  end

  def method_missing(method, *args, &block)
    @file ||= Tempfile.new(@basename, *@rest)
    puts "%%>" + method.to_s
    @file.send(method, *args, &block)
  end

  def respond_to?(method)
    # @file.respond_to?(method)
    result = @file.respond_to?(method)
    puts "%%>"+ method.to_s + ": " + result.to_s
    return result
  end

  def me
    'Im lazy'
  end

end


object = Object.new
object.extend(Lazyfile::Helper)

object.with_lazyfiles do |file1, file2|
   # file2.write "hello"
   # puts file1.inspect
   # puts file1.path
   # puts file1.read
   puts file1.respond_to?(:path)
end
