#!/opt/local/bin/ruby
# coding: utf-8

require 'minitest/autorun'
require_relative '../lib/sal/command'
require_relative '../lib/sal/code'

class TestCommand < MiniTest::Test
  
  def test_function
    assert_equal(false, Sal::Command.is_code_line?("Message Actions"))
    assert_equal(true, Sal::Command.is_code_line?("Set bOk = TRUE"))
  end
  
end

MiniTest.autorun