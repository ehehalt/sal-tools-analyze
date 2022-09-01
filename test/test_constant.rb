#!/opt/local/bin/ruby
# coding: utf-8

require 'minitest/autorun'
require_relative '../lib/sal/code'
require_relative '../lib/sal/constant'

class TestClass < MiniTest::Test

  def code_class
    # Neue Klasse um die Initialisierung zu umgehen
    code_class = Class.new(Sal::Code) do
      def initialize
      end
    end
    code_class
  end

  def setup
    @lines = []
    @lines << ".head 0 +  Application Description: Gupta SQLWindows Standard Application Template\r\n"
    @lines << ".head 1 +  Global Declarations\r\n"
    @lines << ".head 2 +  Constants\r\n"
    @lines << ".head 3 +  System\r\n"
    @lines << ".head 4 -  SYSTEM_CONSTANT = 253\r\n"
    @lines << ".head 3 +  User\r\n"
    @lines << ".head 4 -  ! USER_CONSTANT = 254\r\n"
    @lines << ".head 4 -  USER_CONSTANT = 255\r\n"
    @source = @lines.join("")

    @code = code_class.new
    @code.code = @source
    @code.format = Sal::Format::TEXT
    @items = @code.send :get_items_from_code
  end

  def test_constants
    assert_equal(2, @code.constants.count)
  end
  
  def test_constants_system
    assert_equal(1, @code.constants_system.count)
  end
  
  def test_constants_user
    assert_equal(1, @code.constants_user.count)
  end
  
  def test_hook
    assert_equal(".head 4 -  SYSTEM_CONSTANT = 253\r\n", @code.constants[0].line)
    assert_equal("SYSTEM_CONSTANT = 253", @code.constants[0].code)
  end
  
  def test_name
    assert_equal("SYSTEM_CONSTANT", @code.constants[0].name)
    assert_equal("USER_CONSTANT", @code.constants[1].name)
  end
  
  def test_value
    assert_equal("253", @code.constants[0].value)
    assert_equal("255", @code.constants[1].value)
  end
  
  def test_system?
    assert_equal(true, @code.constants[0].system?)
    assert_equal(false, @code.constants[1].system?)
  end
  
  def test_user?
    assert_equal(false, @code.constants[0].user?)
    assert_equal(true, @code.constants[1].user?)
  end
    
end

MiniTest.autorun