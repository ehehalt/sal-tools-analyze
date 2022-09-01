#!/opt/local/bin/ruby
# coding: utf-8

require 'minitest/autorun'
require 'pp'
require_relative '../lib/sal/pictab'
require_relative '../lib/sal/code'

class TestPicTab < MiniTest::Test

  def setup
    @file0 = "data/test.40.text.quicktabs.0.app"
    @file1 = "data/test.40.text.quicktabs.1.app"
  end

  def test_pic_tab
    name = "picTabs"
    type = "Picture"
    code = "#{type}: #{name}"
    line = ".head 3 +  #{code}"
    item = Sal::Item.new(line)

    ptab = Sal::PicTab.new(item)

    assert_equal(item, ptab.item)
    assert_equal(name, ptab.name)
    assert_equal(type, ptab.type)
  end

  def test_tab_names_file0
    code = Sal::Code.new(@file0)
    assert_equal(1, code.windows.count)

    window = code.windows.first
    pictab = window.pictab
    assert_equal(false, pictab.nil?)

    assert_equal(2, pictab.tab_names.count)
    assert_equal("Name1", pictab.tab_names[0])
    assert_equal("Name2", pictab.tab_names[1])

    assert_equal(2, pictab.tab_labels.count)
    assert_equal("Label1", pictab.tab_labels[0])
    assert_equal("Label2", pictab.tab_labels[1])
  end

    def test_tab_names_file1
    code = Sal::Code.new(@file1)
    assert_equal(1, code.windows.count)

    window = code.windows.first
    pictab = window.pictab
    assert_equal(false, pictab.nil?)

    pp pictab.item.properties

    assert_equal(4, pictab.tab_names.count)
    assert_equal("Name1", pictab.tab_names[0])
    assert_equal("Name2", pictab.tab_names[1])
    assert_equal("Name3", pictab.tab_names[2])
    assert_equal("Name4", pictab.tab_names[3])

    assert_equal(4, pictab.tab_labels.count)
    assert_equal("Label1", pictab.tab_labels[0])
    assert_equal("Label2", pictab.tab_labels[1])
    assert_equal("Label3", pictab.tab_labels[2])
    assert_equal("Label4", pictab.tab_labels[3])
  end
  
end

MiniTest.autorun