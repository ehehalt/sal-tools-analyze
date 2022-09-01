#!/opt/local/bin/ruby
# coding: utf-8

require 'minitest/autorun'
require_relative '../lib/sal/externalfunction'

class TestExternalFunction < MiniTest::Test

  def get_sample_external
    item = Sal::Item.new(".head 3 +  Library name: Test.dll\r\n")
    item.childs << Sal::Item.new(".head 4 -  ThreadSafe: No\r\n")
    item.childs << get_sample_external_function_item
    return item
  end

  def get_sample_external_function_item
    item = Sal::Item.new(".head 4 +  Function: Func1\r\n")
    item.childs << Sal::Item.new(".head 5 -  Description: ...\r\n")
    item.childs << Sal::Item.new(".head 5 -  Export Ordinal: 111\r\n")
    returns = Sal::Item.new(".head 5 +  Returns\r\n")
    returns.childs << Sal::Item.new(".head 6 -  Number: LONG\r\n")
    item.childs << returns
    parameters = Sal::Item.new(".head 5 +  Parameters\r\n")
    parameters.childs << Sal::Item.new(".head 6 -  Date/Time: HARRAY\r\n")
    parameters.childs << Sal::Item.new(".head 6 -  ! Number: HARRAY\r\n")
    parameters.childs << Sal::Item.new(".head 6 -  Date/Time: DATETIME\r\n")
    item.childs << parameters
    return item
  end
    
  def test_item_file_include
    f1_name = "Func1"
    f1_code = "Function: #{f1_name}"
    f1_line = ".head 4 +  #{f1_code}\r\n"
    f1_item = Sal::Item.new(f1_line)
    
    x1_code = "! Description"
    x1_line = ".head 4 -  #{x1_code}\r\n"
    x1_item = Sal::Item.new(x1_line)
    
    l_name = "Test.dll"
    l_code = "Library name: #{l_name}"
    l_line = ".head 3 +  #{l_code}\r\n"
    l_item = Sal::Item.new(l_line)
    
    l_item.childs << f1_item
    l_item.childs << x1_item
    
    assert_equal(2, l_item.childs.count)
    extlib = Sal::External.new(l_item)
    
    assert_equal(l_item, extlib.item)
    assert_equal(l_name, extlib.name)
    
    assert_equal(1, extlib.functions.count)
    
    extfunc = extlib.functions[0]
    assert_equal(f1_name, extfunc.name)
  end

  def test_item_ordinal
    item = get_sample_external
    library = Sal::External.new(item)
    refute_equal(nil, library)
    assert_equal(1, library.functions.count)
    
    function = library.functions[0]
    refute_equal(nil, function)
    assert_equal("Func1", function.name)
    assert_equal(111, function.ordinal)
    assert_equal("Test.dll::Func1", function.key)
    assert_equal(2, function.parameters.count)
    assert_equal(Sal::Item, function.parameters[0].class)
  end
end

MiniTest.autorun