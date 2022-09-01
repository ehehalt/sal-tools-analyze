#!/opt/local/bin/ruby
# coding: utf-8

require 'minitest/autorun'
require_relative '../lib/sal/item'
require_relative '../lib/sal/code'

class TestItem < MiniTest::Test

  def setup
    @lines = []
    @lines << ".head 0 +  Application Description: Gupta SQLWindows Standard Application Template\r\n"
    @lines << ".head 1 +  ! Outline Version - 4.0.34\r\n"
    @lines << ".head 2 +  Set bCommented = TRUE\r\n"
    @lines << ".head 3 -  ! Set bCommented = TRUE\r\n"
    
    @items = []
    parent = nil
    @lines.each do | line |
      item = Sal::Item.new(line, Sal::Format::TEXT)
      item.parent = parent unless parent.nil?
      parent.childs << item unless parent.nil?
      parent = item
      @items << item
    end

    @files = []
    @files << "data/test.63.text.cgwcalcgw.app"
  end
  
  def test_item_outline_version_text
    code = "Outline Version - 4.0.34"
    line = ".head 1 -  #{code}\r\n"
    item = Sal::Item.new(line)
    
    assert_equal(line, item.line)
    assert_equal(Sal::Format::TEXT, item.format)
    assert_equal(1, item.level)
    assert_equal(false, item.commented?)
    assert_equal(nil, item.parent)
    assert_equal(0, item.childs.count)
    assert_equal(code, item.code)
    assert_equal(true, item.analyzed?)
    assert_equal(-1, item.code_line_nr)
    assert_equal(nil, item.tag)
  end

  def test_item_outline_version_indented
    code = "Outline Version - 4.0.34"
    line = "\t#{code}\r\n"
    item = Sal::Item.new(line)
    
    assert_equal(line, item.line)
    assert_equal(Sal::Format::INDENTED, item.format)
    assert_equal(1, item.level)
    assert_equal(false, item.commented?)
    assert_equal(nil, item.parent)
    assert_equal(0, item.childs.count)
    assert_equal(code, item.code)
    assert_equal(true, item.analyzed?)
    assert_equal(-1, item.code_line_nr)
    assert_equal(nil, item.tag)
  end

  def test_item_file_include
    code = "File Include: qckttip.apl"
    line = ".head 2 -  #{code}\r\n"
    item = Sal::Item.new(line)
    
    assert_equal(line, item.line)
    assert_equal(line, item.original)
    assert_equal(Sal::Format::TEXT, item.format)
    assert_equal(2, item.level)
    assert_equal(false, item.commented?)
    assert_equal(nil, item.parent)
    assert_equal(0, item.childs.count)
    assert_equal(true, item.analyzed?)
    assert_equal(code, item.code)
    assert_equal(-1, item.code_line_nr)
    assert_equal(nil, item.tag)
  end
  
  def test_item_commented
    commented = 0
    item_commented = 0
    
    @items.each do | item |
      commented += 1 if item.commented?
      item_commented += 1 if item.item_commented?
    end
    
    assert_equal(3, commented)
    assert_equal(2, item_commented)
  end
  
  def test_item_count
    assert_equal(1, @items.find_all {|item| item.level == 1 }.length)
  end
  
  def test_is_code_line
    counter = 0
    @items.each do | item |
      counter += 1 if item.is_code_line?
    end
    assert_equal(1, counter, "Count of code lines in sample code")
  end
  
  def test_item_code_multiline
    code = Sal::Code.new("data/test.40.text.multiline.app")
    code.items.each do | item |
      if item.code =~ /^Set /
        assert_equal(2, item.code.each_line.to_a.length)
      end
    end
  end
  
  def test_item_comment
    code = "File Include: qckttip.apl"
    line = ".head 2 -  #{code}\r\n"
    item = Sal::Item.new(line)
    item.item_comment
    assert_equal("! #{code}", item.code)
  end
  
  def test_item_comment_not_commented_failure
  	codelines = []
  	codelines << ".head 12 +  If nFertigProz AND nFertigProz != nFertigProzOld \r\n"
  	codelines << "\tOR nProzStatus AND nProzStatus != nProzStatusOld \r\n"
  	codelines << "\tOR dNextFaelligDat AND dNextFaelligDat != dNextFaelligDatOld\r\n"
  	codelines << "\tOR m_bIsDirty != bIsDirty\r\n"
  	codelines << "\t\t\t! OR bRechekProzess != bRechekProzessOld"
  	line = codelines.join
  	item = Sal::Item.new(line)
  	assert_equal( line, item.line )
  	assert_equal( false, item.commented?, "Commented should be false, because it is not a comment" )
  end
  
  def test_insert_new_child
	  code = "File Include: qckttip.apl"
    line = ".head 2 -  #{code}\r\n"
    item = Sal::Item.new(line)
	  assert_equal(0, item.childs.count)
	  assert_equal("-", item.child_indicator)
	  new_item = item.insert_new_child("! Hello World")
	  assert_equal(1, item.childs.count)
	  assert_equal("+", item.child_indicator)
	  assert_equal(".head 3 -  ! Hello World\r\n", new_item.line)
	  assert_equal("! Hello World", new_item.code)
  end
  
  def test_childs_deep
    assert_equal(4, @items[0].childs_deep.count)
    assert_equal(3, @items[1].childs_deep.count)
    assert_equal(2, @items[2].childs_deep.count)
    assert_equal(1, @items[3].childs_deep.count)
  end

  def test_path_part
    code = "Data Field: df1"
    line = ".head 2 -  #{code}"
    item = Sal::Item.new(line)
    assert_equal("df1", item.path_part)
  end

  def test_path
    code0 = "Form Window: frm1"
    line0 = ".head 1 -  #{code0}"
    item0 = Sal::Item.new(line0)
    assert_equal("frm1", item0.path)

    code1 = "Data Field: df1"
    line1 = ".head 2 -  #{code1}"
    item1 = Sal::Item.new(line1)
    item1.parent = item0
    assert_equal("df1", item1.path_part)

    assert_equal("frm1::df1", item1.path)
  end

  def test_path_in_file
    code = Sal::Code.new(@files[0])
    assert_equal(code.items.count, 628)
    code.items.each do | item |
      puts item.path + item.code if /cgw.*?cgw/ =~ "#{item.path}::#{item.code}"
    end
  end

end

MiniTest.autorun
