#!/opt/local/bin/ruby
# coding: utf-8

require 'minitest/autorun'
require_relative '../lib/sal/format'

class TestFileFormat < MiniTest::Test

  def setup
    @files = []
    @files << "data/test.40.indented.app"
    @files << "data/test.40.text.app"
    @files << "data/test.40.normal.app"
    @files << "data/test.41.indented.app"
    @files << "data/test.41.text.app"
    @files << "data/test.41.normal.app"
    @files << "data/test.21.text.sql.app"
    @files << "data/test.62.indented.app"
    @files << "data/test.62.text.app"
    @files << "data/test.62.normal.app"
  end
  
  def test_file_format
    #@files.grep(/\.indented\./).each do | file |
    #  assert_equal( Sal::Format::INDENTED, Sal::Format.get_from_file(file), file )
    #end
    
    @files.grep(/\.text\./).each do | file |
      assert_equal( Sal::Format::TEXT, Sal::Format.get_from_file(file), file )
    end
    
    @files.grep(/\.normal\./).each do | file |
      assert_equal( Sal::Format::NORMAL, Sal::Format.get_from_file(file), file )
    end
  end
  
  def test_get_from_code
    assert_equal(   Sal::Format::TEXT, 
                    Sal::Format.get_from_code(".head 1 -  Outline Version - 4.0.34"))
    assert_equal(   Sal::Format::INDENTED,
                    Sal::Format.get_from_code("Outline Version - 4.0.34"))
    assert_equal(   Sal::Format::NORMAL,
                    Sal::Format.get_from_code("01234567890"))                
  end

  def test_check_constants
    assert_equal( Sal::Format::TEXT, :t )
    refute_equal( Sal::Format::TEXT, "t" )              
    assert_equal( Sal::Format::NORMAL, :n )
    refute_equal( Sal::Format::NORMAL, "n" )
    assert_equal( Sal::Format::INDENTED, :i )
    refute_equal( Sal::Format::INDENTED, "i" )
  end

  def test_get_from_line
    assert_equal( Sal::Format::TEXT, Sal::Format.get_from_line(".head 5 - ..."))
    assert_equal( Sal::Format::INDENTED, Sal::Format.get_from_line("Application Description"))
    assert_equal( Sal::Format::INDENTED, Sal::Format.get_from_line("	Design-time Settings"))
  end
end

MiniTest.autorun