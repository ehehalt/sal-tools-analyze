#!/usr/bin/env ruby
# coding: utf-8

require 'minitest/autorun'
require 'pp'
require_relative '../lib/sal/code'

class TestQuickTabsAnalyse < MiniTest::Test
  
  def setup
    @file0 = "data/test.40.text.quicktabs.0.app"
    @file1 = "data/test.40.text.quicktabs.1.app"
    @file2 = "data/test.63.text.quicktabs.0.app"
    @file3 = "data/test.63.text.quicktab2tabbar.0.app"
    # @file4 = "data/test.40.text.flstverw.app"
 end

  def test_find_pictabs_0
    code = Sal::Code.new(@file2)

    # assert_equal(353, code.items.count) # @file0
    # assert_equal(398, code.items.count) # @file1
    # assert_equal(452, code.items.count) # @file2
    # assert_equal(482, code.items.count) # @file3

    picTab = code.items.select { | item | item.code =~ /(Picture|Tab Bar): picTab/ }.first
    assert_equal(false, picTab.nil?, "picTab nicht gefunden")

    pb1 = code.items.select { | item | item.code =~ /Pushbutton: pb1/ }.first
    assert_equal(false, pb1.nil?, "pb1 nicht gefunden")

    pb1visible = pb1.childs.select { | item | item.code =~ /Visible\? (Yes|No)/ }.first
    assert_equal(true, pb1visible.code.end_with?("Yes"), "pb1 ist nicht visible!")

    pb2 = code.items.select { | item | item.code =~ /Pushbutton: pb2/ }.first
    assert_equal(false, pb2.nil?, "pb2 nicht gefunden")

    pb2visible = pb2.childs.select { | item | item.code =~ /Visible\? (Yes|No)/ }.first
    assert_equal(true, pb2visible.code.end_with?("No"), "pb2 ist visible!")
  end

  def test_change_tab_to_tab_bar
    code = Sal::Code.new(@file2)

    # assert_equal(353, code.items.count) # @file0
    # assert_equal(398, code.items.count) # @file1
    # assert_equal(452, code.items.count) # @file2
    # assert_equal(482, code.items.count) # @file3

    puts " => picTab to Tab Bar"
    picTab = code.items.select { | item | item.code =~ /(Picture|Tab Bar): picTab/ }.first
    
    # pp picTab.properties

    tabNames = picTab.properties.select { | prop | prop.key == "TabNames"}.first

    pp tabNames.value

    puts "Original: #{picTab.code}"
    picTab.code_behind_data = ""
    picTab.code ="Tab Bar: picTabs"
    puts " Changed: #{picTab.code}"

    picTabClass = picTab.childs.select { | item | item.code =~ /Class: cQuickTabsForm/ }.first
    picTabClass.code = "Class: cTabControl"

    pb1 = code.items.select { | item | item.code =~ /Pushbutton: pb1/ }.first
    # puts "--- pb1 --- #{pb1.nil? ? "not found" : "found"}"
    pp pb1.properties

    # pb1visible = pb1.childs.select { | item | item.code =~ /Visible\?/ }.first
    # puts pb1visible.nil? ? "Visible? not found" : pb1visible.original

    # pb2 = code.items.select { | item | item.code =~ /Pushbutton: pb2/ }.first
    # puts "--- pb2 --- #{pb2.nil? ? "not found" : "found"}"
    # pp pb2.properties
    # pb2visible = pb2.childs.select { | item | item.code =~ /Visible\?/ }.first
    # puts pb2visible.nil? ? "Visible? not found" : pb2visible.original
  end

  def x_test_quick_tab_to_markdown
    code = Sal::Code.new(@file4)

    windows = code.windows
    pictabs = []
    windows.each do | window |
      if window.item.childs_flat.detect { | child | child.code =~ /Picture: picTabs/ }
        pictabs << window
      end
    end
    
    pictabs.sort_by { | window | window.code }.each do | window |
      puts "# #{window.code}"
    end
    
    puts "#{pictabs.count} picTab Fenster gefunden!"


#    classes = code.classes
#    pictab_classes = []
#    classes.each do | cls |
#      if cls.item.childs_flat.detect { | child | child.code =~ /Picture: picTabs/ }
#        pictab_classes << cls.item
#      end
#    end
#    puts "#{pictab_classes.count} picTab Fensterklassen gefunden!"
  end
  
end

MiniTest.autorun