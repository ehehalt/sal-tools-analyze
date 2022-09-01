#!/opt/local/bin/ruby
# coding: utf-8

require 'minitest/autorun'
require 'ostruct'
require 'pp'

require_relative '../lib/sal/code'
require_relative '../lib/sal/format'
require_relative '../lib/sal/constant'

class TestCode < MiniTest::Test

  def setup
    @files = []
    @files << "data/test.40.indented.app"
    @files << "data/test.40.text.app"
    @files << "data/test.40.normal.app"
    @files << "data/test.41.indented.app"
    @files << "data/test.41.text.app"
    @files << "data/test.41.normal.app"
    @files << "data/test.51.normal.app"
    @files << "data/test.51.text.app"
    @files << "data/test.52.normal.externalfunctions.app"
    @files << "data/test.52.text.externalfunctions.app"
    @files << "data/test.60.normal.externalfunctions.app"
    @files << "data/test.60.text.externalfunctions.app"
    
    @files52 = []
    @files52 << "data/test.52.text.app"
    # @files52 << "data/test.52.compiled.externalfunctions.app"

    @file_with_window0 = "data/test.11.text.app"
    @file_with_window1 = "data/test.40.text.quicktabs.0.app"
    @file_with_window2 = "data/test.40.text.quicktabs.1.app"

    @files_appstartup = []
    @files_appstartup << "data/test.21.text.sql.app" # idx = 0 = kein App Startup Item
    @files_appstartup << "data/test.21.text.appstartup.app" # idx = 1 = App Startup Item vorhanden
    
    @lines = []
    @lines << ".head 0 +  Application Description: Gupta SQLWindows Standard Application Template\r\n"
    @lines << ".head 1 -  Outline Version - 4.0.34\r\n"
    
    @include1 = []
    @include1 << ".head 0 +  Application Description: File Include Test\r\n"
    @include1 << ".head 1 -  Outline Version - 4.0.34\r\n"
    @include1 << ".head 1 +  Libraries\r\n"
    @include1 << ".head 2 -  File Include: qckttip.apl\r\n"
    @include1 << ".head 1 +  Constants\r\n"
    
    @include2 = []
    @include2 << ".head 0 +  Application Description: File Include Test\r\n"
    @include2 << ".head 1 -  Outline Version - 4.0.34\r\n"
    @include2 << ".head 1 -  Libraries\r\n"
    @include2 << ".head 1 +  Constants\r\n"
  end
  
  def code_class
    # Neue Klasse um die Initialisierung zu umgehen
    code_class = Class.new(Sal::Code) do
      def initialize
      end
    end
    code_class
  end
  
  def test_filename
    filename = @files[0] 
    assert_equal(filename, Sal::Code.new(filename).filename)
  end
  
  def test_file_format
    @files.grep(/\.indented\./).each do | file |
      assert_equal( Sal::Format::INDENTED, Sal::Code.new(file).format )
    end
    
    @files.grep(/\.text\./).each do | file |
      assert_equal( Sal::Format::TEXT, Sal::Code.new(file).format )
    end
    
    @files.grep(/\.normal\./).each do | file |
      assert_equal( Sal::Format::NORMAL, Sal::Code.new(file).format )
    end
  end

  def test_version
    @files.each do | file |
      file =~ /\.(\d)(\d)\./
      tdversion = "#{$1}.#{$2}"
      assert_equal( tdversion, Sal::Code.new(file).version.td )
    end
  end
  
  def test_libraries
    # assert_equal(2, Sal::Code.new("data/test.40.indented.app").libraries.length)
    assert_equal(2, Sal::Code.new("data/test.40.text.app").libraries.length)
    # assert_equal(0, Sal::Code.new("data/test.41.indented.app").libraries.length)
    assert_equal(0, Sal::Code.new("data/test.41.text.app").libraries.length)
  end
  
  def test_constants_system
    code = Sal::Code.new("data/test.51.text.app")
	  assert_equal(11, code.constants.count)
    assert_equal(11, code.constants_system.count)
	  assert_equal(0, code.constants_user.count)
  end
  
  def test_constants_user
    code = Sal::Code.new("data/test.11.text.app")
	    assert_equal(1, code.constants.count)
    assert_equal(0, code.constants_system.count)
	assert_equal(1, code.constants_user.count)
  end
  
  def test_private_get_item
    
    @lines.each do | line |
      # Initialisierungen
      vars = OpenStruct.new
      vars.counter = 0
      vars.levels = Hash.new
      vars.format = Sal::Format::TEXT
      vars.lines = @lines
      vars.line = line
      
      # Level extrahieren
      line =~ /^.head.+?(\d+).+/
      level = $1.to_i
      # Quellcode holen
      # line =~ /^.head.+?\d+.+?(\w.*?)(\r\n)+.*$/m
      line =~/(^\.head )(\d+?)( )([+-])(  )(.*?)(\r\n.*)/m
      code_part= $6
      
      # Das private get_item aufrufen
      code = code_class.new
      item = code.send :get_item, vars
      
      # Tests
      assert_equal(level, item.level, line)
      assert_equal(line, item.line, line)
      assert_equal(vars.format, item.format)
      assert_equal(false, item.commented?)
      assert_equal(nil, item.parent)
      assert_equal(0, item.childs.count)
      assert_equal(1, item.code_line_nr)
      assert_equal(true, item.analyzed?)
      assert_equal(code_part, item.code)
    end
    
  end
  
  def test_add_library_to_existing_libraries
    code = code_class.new
    code.code = @include1.join()
    code.send :get_format_and_version_from_code
    itemcount = code.items.count
    libcount = code.libraries.count
    libname = "test.apl"
    
    code.add_library(libname)
    
    assert_equal(itemcount + 1, code.items.count)
    assert_equal(libcount + 1, code.libraries.count)
    assert_equal(libname, code.libraries[0].name)
  end
  
  def test_add_library_as_first_library
    code = code_class.new
    code.code = @include2.join()
    code.send :get_format_and_version_from_code
    itemcount = code.items.count
    libcount = code.libraries.count
    libname = "test.apl"
    
    code.add_library(libname)
    
    assert_equal(itemcount + 1, code.items.count)
    assert_equal(libcount + 1, code.libraries.count)
    assert_equal(libname, code.libraries[0].name)
  end
  
  def test_private_code_split_text
    vars = OpenStruct.new
    vars.lines = []
    code = code_class.new
    code.code = @lines.join("\r\n")
    code.send :code_split_text, vars
    
    assert_equal(2,vars.lines.length)
  end
  
  def test_code_binary_data
    source = <<END_OF_STRING
.head 2 -  External Functions
.head 2 +  Constants
.data CCDATA
0000: 3000000000000000 0000000000000000 00000000
.enddata
.data CCSIZE
0000: 1400
.enddata
.head 3 -  System
END_OF_STRING
    code = code_class.new
    code.code = source
    code.format = Sal::Format::TEXT
    items = code.send :get_items_from_code
    assert_equal(true, items[1].include?(".data CCDATA"))
    assert_equal(true, items[1].include?(".data CCSIZE"))
  end
  
  def test_app_startup_item
    assert_equal(nil, Sal::Code.new(@files_appstartup[0]).app_startup_item)
    app_startup_item = Sal::Code.new(@files_appstartup[1]).app_startup_item
    refute_nil(app_startup_item)
    assert_equal(2, app_startup_item.childs.count)
  end
  
  def test_indented_exception
    filename = @files[0] 
    assert_raises(Sal::CodeException) do
      Sal::Code.new(filename).items
    end
  end
  
  def test_remove_item
    code = code_class.new
    code.code = @include1.join()
    code.format = Sal::Format::TEXT
    code.send :get_format_and_version_from_code
    item = code.items[2]
    assert_equal("Libraries", item.code)
    assert_equal(5, code.items.count)
    code.remove_item(item)
    assert_equal(3, code.items.count)
  end

  def test_parts
    filename = "data/test.11.text.app"

    # use parts = :all (defaultparameter)
    code1 = Sal::Code.new(filename)
    assert_equal(392, code1.items.count)

    # use parts = :all
    code2 = Sal::Code.new(filename, :all)
    assert_equal(392, code2.items.count)

    # use parts = :ver
    code3 = Sal::Code.new(filename, :ver)
    assert_equal(1, code3.items.count)
    assert_equal("1.1", code3.version.td)

    # use parts = :lib (0 libs vorhanden)
    code4 = Sal::Code.new(filename, :lib)
    assert_equal(1, code4.items.count)

    # use parts = :lib (2 libs vorhanden)
    code5 = Sal::Code.new("data/test.40.text.app", :lib)
    assert_equal(3, code5.items.count)
    assert_equal(2, code5.libraries.count)
  end

  def test_windows
    code0 = Sal::Code.new(@file_with_window0)
    assert_equal(0, code0.windows.count)

    code1 = Sal::Code.new(@file_with_window1)
    assert_equal(1, code1.windows.count)

    code2 = Sal::Code.new(@file_with_window2)
    assert_equal(1, code2.windows.count)
  end

  def test_has_quicktabs
    code0 = Sal::Code.new(@file_with_window1)
    assert_equal(true, code0.has_quicktabs?)
  end
end

MiniTest.autorun