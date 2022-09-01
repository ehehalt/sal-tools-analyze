#!/opt/local/bin/ruby
# coding: utf-8

require 'minitest/autorun'
require_relative '../lib/sal/library'
require_relative '../lib/sal/code'
require_relative '../lib/sal/item'

class TestLibrary < MiniTest::Test

  def test_item_file_include
    name = "qckttip.apl"
    code = "File Include: #{name}"
    line = ".head 2 -  #{code}\r\n"
    item = Sal::Item.new(line)
    
    library = Sal::Library.new(item)
    
    assert_equal(item, library.item)
    assert_equal(name, library.name)
  end

  def test_libraries
    libraries = Sal::Code.new("data/test.40.text.app").libraries
    assert_equal(2, libraries.length)
    assert_equal("qckttip.apl", libraries[0].name)
    assert_equal("vt.apl", libraries[1].name)
  end
  
  def test_get_name
    item = Sal::Item.new("")
    lib = Sal::Library.new(item)
    assert_equal("test", lib.send(:get_name,"File Include: test"))
    assert_equal("test", lib.send(:get_name,"File Include: test ! jacka"))
  end
  
end

MiniTest.autorun