#!/opt/local/bin/ruby
# coding: utf-8

require 'minitest/autorun'

require_relative '../lib/sal/codehelper'

class TestCodeHelper < MiniTest::Test

  def setup
    @utf_files = []
    @utf_files << "data/test.51.text.app"
    @utf_files << "data/test.52.text.externalfunctions.app"
    @utf_files << "data/test.60.text.externalfunctions.app"
    @utf_files << "data/test.61.text.app"
    
    @ansi_files = []
    @ansi_files << "data/test.11.text.app"
    @ansi_files << "data/test.21.text.sql.app"
    @ansi_files << "data/test.30.text.app"
    @ansi_files << "data/test.31.text.app"
    @ansi_files << "data/test.40.text.app"
    @ansi_files << "data/test.41.text.app"
    @ansi_files << "data/test.42.text.app"
  end
  
  def test_is_utf16le?
    @ansi_files.each do | file |
      assert_equal( false, Sal::CodeHelper.utf16le?( File.binread(file) ), "File #{file}" )
    end
    
    @utf_files.each do | file |
      assert_equal( true, Sal::CodeHelper.utf16le?( File.binread(file) ), "File #{file}" )
    end
  end
  
end


MiniTest.autorun
