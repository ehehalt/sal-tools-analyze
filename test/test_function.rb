#!/opt/local/bin/ruby
# coding: utf-8

require 'minitest/autorun'
require_relative '../lib/sal/function'

class TestFunction < MiniTest::Test

  def test_function
    name = "Name"
    code = "Function: #{name}"
    line = ".head 5 +  #{code}\r\n"
    item = Sal::Item.new(line)
    
    func = Sal::Function.new(item)
    
    assert_equal(item, func.item)
    assert_equal(name, func.name)
  end
  
end

MiniTest.autorun