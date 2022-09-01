#!/opt/local/bin/ruby
# coding: utf-8

require 'minitest/autorun'
require_relative '../lib/sal/window'
require_relative '../lib/sal/code'

class TestWindow < MiniTest::Test

  def setup
    @file0 = "data/test.40.text.quicktabs.0.app"
    @file1 = "data/test.40.text.quicktabs.1.app"
  end

  def test_window
    name = "frm1"
    type = "Dialog Box"
    code = "#{type}: #{name}"
    line = ".head 1 +  #{code}"
    item = Sal::Item.new(line)

    wndw = Sal::Window.new(item)

    assert_equal(item, wndw.item)
    assert_equal(name, wndw.name)
    assert_equal(type, wndw.type)
    assert_nil(wndw.pictab)
  end
  
  def test_pictab
    code = Sal::Code.new(@file0)
    windows = code.windows
    assert_equal(1, windows.count)
    window = windows.first
    assert_equal(false, window.pictab.nil?)
    assert_equal("Picture", window.pictab.type)
    assert_equal("picTabs", window.pictab.name)
  end

  def test_contents
    code = Sal::Code.new(@file0)
    contents = code.windows.first.contents
    assert_equal(false, contents.nil?)
    assert_equal(true, contents.count > 0)

    filtered = contents.select{ | item | item.tab_names != nil }
    # assert_equal(3, filtered.count)

    pb1 = filtered.select{ | item | item.code =~ /pb1/ }.first
    assert_equal(["Name1"], pb1.tab_names)

    pb2 = filtered.select{ | item | item.code =~ /pb2/ }.first
    assert_equal(["Name2"], pb2.tab_names)

    pb3 = filtered.select{ | item | item.code =~ /pb3/ }.first
    assert_equal(["Name1", "Name2"], pb3.tab_names)
  end

end

MiniTest.autorun