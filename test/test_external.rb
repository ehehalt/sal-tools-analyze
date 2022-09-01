#!/opt/local/bin/ruby
# coding: utf-8

require 'minitest/autorun'
require_relative '../lib/sal/external'
require_relative '../lib/sal/code'

class TestExternal < MiniTest::Test

  def test_item_external
    name = "vti41.dll"
    code = "Library name: #{name}"
    line = ".head 3 +  #{code}\r\n"
    item = Sal::Item.new(line)
    
    extlib = Sal::External.new(item)
    
    assert_equal(item, extlib.item)
    assert_equal(name, extlib.name)
  end
  
  def test_external_none_in_file
    code = Sal::Code.new('data/test.40.text.app')
    libs = code.externals
    assert_equal(0, libs.count)
  end
  
  def test_external_in_file
    code = Sal::Code.new('data/test.41.text.externalfunctions.app')
    libs = code.externals
    assert_equal(1, libs.count)
    funcs = libs[0].functions
    assert_equal(11, funcs.count)
  end

end

MiniTest.autorun