#!/opt/local/bin/ruby
# coding: utf-8

require 'minitest/autorun'
require_relative '../lib/sal/class'
require_relative '../lib/sal/code'

class TestClass < MiniTest::Test

  def test_class
    name = "Test"
    type = "Functional Class"
    code = "#{type}: #{name}"
    line = ".head 3 +  #{code}\r\n"
    item = Sal::Item.new(line)
    
    clas = Sal::Class.new(item)
    
    assert_equal(item, clas.item)
    assert_equal(name, clas.name)
    assert_equal(type, clas.type)
  end
  
  def test_libraries
    code = Sal::Code.new("data/test.40.text.classes.app")
    assert_equal(2, code.classes.length)
    assert_equal("BaseClass", code.classes[0].name)
    assert_equal("ClassName", code.classes[1].name)
    assert_equal(1, code.classes[1].functions.length)
    # assert_equal("functionName", code.classes[1].functions[0].name)
  end
  
end

MiniTest.autorun