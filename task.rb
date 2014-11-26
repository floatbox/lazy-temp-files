#!/usr/bin/env ruby

# Synopsis
#
# Данное задание предназначалось для Ruby 1.9.3-p194 и выше
#
# Нам нужен хелпер-метод, который мы можем включить в любой класс. Этот хелпер
# должен принимать блок и присваивать объекты ленивых темп-файлов в каждый
# аргумент данного блока, сколько бы аргументов не было.
#
# Например
#
# with_lazyfiles do |file1, file2, file3|
#   file2.write "hello"
# end
#
# Все темп-файлы должны быть удалены по истечении блока.
#
# Что такое ленивые темп-файлы?
# Темп-файлы не должны быть созданы, пока они не оказались востребованны внутри
# блока. То есть в данном примере, file1 и file3 никогда физически не должны
# быть созданы, потому что мы их не использовали. В остальном, они должны
# полностью работать как обычные Tempfile объекты из ruby stdlib. Также, все
# названия темп-файлов (в файловой системе) должны начинаться со слова
# "printio".
#
# При запуске данного скрипта - тесты проигрываются автоматически. Их менять,
# конечно-же, нельзя. Они должны все быть удовлетворены кодом, который нужно
# добавить сразу после данного комментария:

## Исправленные замечания
#[x] 1. close | unlink
#[x] 2. *block_params
#[x] 3. respond_to?
#[x] 4. block ensure

# [Код должен быть здесь]
class Lazyfile
  module Helper

    def with_lazyfiles(&block)
      files = Array.new(block.arity) do |file|
        file = Lazyfile.new('printio')
      end
      begin
        yield *files if block_given?
      ensure
        files.each{ |file| file.destroy }
      end
    end

  end

  def initialize(basename, *rest)
    @basename = basename
    @rest = rest
  end

  def method_missing(method, *args, &block)
    @file ||= Tempfile.new(@basename, *@rest)
    @file.send(method, *args, &block)
  end

  def respond_to_missing?(method, include_private = false)
    Tempfile.method_defined? method
  end

  def destroy
    if @file
      @file.close
      @file.unlink
      remove_instance_variable(:@file)
    end
  end
end


if $0 == __FILE__
  require 'test/unit'
  require 'tempfile'

  class LazyfileTest < Test::Unit::TestCase
    def setup
      @object = Object.new
      @object.extend(Lazyfile::Helper)
    end

    def teardown
      Dir["#{Dir.tmpdir}/printio*"].each do |path|
        File.unlink(path)
      end
    end

    def test_object_receives_helper_method
      assert_respond_to @object, :with_lazyfiles
    end

    def test_helper_runs_block
      foo = false
      @object.with_lazyfiles { foo = true }
      assert foo, 'Expected with_lazyfiles block to be executed'
    end

    def test_helper_creates_2_tempfiles_when_passed_2_arguments
      @object.with_lazyfiles do |a, b|
        [a, b].each do |arg|
          assert arg.is_a?(Lazyfile),
            'Expected argument to be a Lazyfile object'
        end
      end
    end

    def test_helper_creates_5_tempfiles_when_passed_5_arguments
      @object.with_lazyfiles do |a, b, c, d, e|
        [a, b, c, d, e].each do |arg|
          assert arg.is_a?(Lazyfile),
            'Expected argument to be a Lazyfile object'
        end
      end
    end

    def test_helper_creates_only_referenced_tempfile
      @object.with_lazyfiles do |file1, file2|
        assert_empty Dir["#{Dir.tmpdir}/printio*"]
        assert_match /^printio/, File.basename(file1.path)
        assert Dir["#{Dir.tmpdir}/printio*"].one?,
          'Expected only one temp file to exist'
      end
    end

    def test_helper_cleans_up_after_itself
      @object.with_lazyfiles do |file1, file2, file3|
        file1.path
        file2.path
        assert_equal 2, Dir["#{Dir.tmpdir}/printio*"].size
      end

      assert_empty Dir["#{Dir.tmpdir}/printio*"]
    end

    def test_files_respond_to_common_tempfile_methods
      @object.with_lazyfiles do |file|
        [:path, :size, :close, :open, :unlink].each do |method_name|
          assert_respond_to file, method_name
        end
      end
    end

    def test_respond_to_does_not_create_tempfile
      @object.with_lazyfiles do |file|
        file.respond_to?(:path)
        assert_empty Dir["#{Dir.tmpdir}/printio*"]
      end
    end
  end
end
