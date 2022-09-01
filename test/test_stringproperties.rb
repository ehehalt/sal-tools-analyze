#!/opt/local/bin/ruby
# coding: utf-8

require 'minitest/autorun'
require 'pp'

require_relative '../lib/sal/item'
require_relative '../lib/sal/stringproperties'
require_relative '../lib/sal/code'

class TestStringProperties < MiniTest::Test
  
  def test_code_behind_data
    assert_equal(@item1.code_behind_data, @strprops1.data)
    assert_equal(10, @strprops1.data.lines.count)
  end
  
  def test_code_behind_names
    names = @strprops1.group_names
    assert_equal(3, names.keys.count)
    
    assert_equal(true, names.keys.include?(:size))
    assert_equal(true, names.keys.include?(:props))
    assert_equal(true, names.keys.include?(:inherit))
    
    assert_equal("CLASSPROPSSIZE", names[:size])
    assert_equal("CLASSPROPS", names[:props])
    assert_equal("INHERITPROPS", names[:inherit])
  end
  
  def test_code_behind_values
    values = @strprops1.group_data
    assert_equal(3, values.keys.count)
    
    assert_equal(true, values.keys.include?(:size))
    assert_equal(true, values.keys.include?(:props))
    assert_equal(true, values.keys.include?(:inherit))
  end
  
  def test_properties_ascii
    properties = @strprops3.properties
    assert_equal(10, properties.count)
    assert_equal(10, @item3.properties.count)
    
    # Das erste Element
    assert_equal("TabLeftMargin", properties[0].key)
    assert_equal(0, properties[0].value)
    assert_equal(:number, properties[0].type)
    
    # Das letzte Element
    assert_equal("TabTopMargin", properties[-1].key)
    assert_equal(0, properties[0].value)
    assert_equal(:number, properties[0].type)
    
    # Ein Element vom Typ Array
    assert_equal("TabLabels", properties[4].key)
    assert_equal(2, properties[4].value.count)
    assert_equal(:array, properties[4].type)
    assert_equal("Label2", properties[4].value[1])
    
    # Ein Element vom Typ String
    assert_equal("TabCurrent", properties[1].key)
    assert_equal("Name1", properties[1].value)
    assert_equal(:string, properties[1].type)

    # Ein Element vom Typ Value
    assert_equal("TabDrawStyle", properties[7].key)
    assert_equal("Win95Style", properties[7].value)
    assert_equal(:value, properties[7].type)    
  end
  
  def test_properties_ascii
    properties = @strprops3.properties
    assert_equal(10, properties.count)
    
    # Das erste Element
    assert_equal("TabLeftMargin", properties[0].key)
    assert_equal(0, properties[0].value)
    assert_equal(:number, properties[0].type)
    
    # Das letzte Element
    assert_equal("TabTopMargin", properties[-1].key)
    assert_equal(0, properties[0].value)
    assert_equal(:number, properties[0].type)
    
    # Ein Element vom Typ Array
    assert_equal("TabLabels", properties[4].key)
    assert_equal(2, properties[4].value.count)
    assert_equal(:array, properties[4].type)
    assert_equal("Label2", properties[4].value[1])
    
    # Ein Element vom Typ String
    assert_equal("TabCurrent", properties[1].key)
    assert_equal("Name1", properties[1].value)
    assert_equal(:string, properties[1].type)

    # Ein Element vom Typ Value
    assert_equal("TabDrawStyle", properties[7].key)
    assert_equal("Win95Style", properties[7].value)
    assert_equal(:value, properties[7].type)    
  end
  
  def test_properties_utf16
    properties = @strprops2.properties
    assert_equal(11, properties.count)
    
    # Das erste Element
    assert_equal("TabLeftMargin", properties[0].key)
    assert_equal(0, properties[0].value)
    assert_equal(:number, properties[0].type)
    
    # Das letzte Element
    assert_equal("TabOrientation", properties[-1].key)
    assert_equal(0, properties[0].value)
    assert_equal(:number, properties[0].type)
    
    # Ein Element vom Typ Array
    assert_equal("TabLabels", properties[4].key)
    assert_equal(2, properties[4].value.count)
    assert_equal(:array, properties[4].type)
    assert_equal("Label2", properties[4].value[1])
    
    # Ein Element vom Typ String
    assert_equal("TabCurrent", properties[1].key)
    assert_equal("Name1", properties[1].value)
    assert_equal(:string, properties[1].type)

    # Ein Element vom Typ Value
    assert_equal("TabDrawStyle", properties[7].key)
    assert_equal("Win95Style", properties[7].value)
    assert_equal(:value, properties[7].type)
  end
  
  def test_ascii_file
	  code = Sal::Code.new("data/test.40.text.quicktabs.0.app")
	  code.items.each do | item |
		  if item.code =~ /picTabs/
			  assert_equal(10, item.properties.count)
		  end
	  end
  end
  
  def test_utf16_file
	  code = Sal::Code.new("data/test.60.text.quicktabs.0.app")
	  code.items.each do | item |
		  if item.code =~ /picTabs/
			  assert_equal(11, item.properties.count)
		  end
	  end
  end
  
  def setup
    @code1 = <<END_OF_STRING
.head 3 +  Pushbutton: pb1
.data CLASSPROPSSIZE
0000: 2C00
.enddata
.data CLASSPROPS
0000: 5400610062004300 680069006C006400 4E0061006D006500 73000000FFFE0C00
0020: 4E0061006D006500 31000000
.enddata
.data INHERITPROPS
0000: 0100
.enddata
END_OF_STRING
    @item1 = Sal::Item.new(@code1)
    @strprops1 = @item1.property_analyzer
	
	  @code2 = <<END_OF_STRING
.head 3 +  Picture: picTabs
.data CLASSPROPS
0000: 5400610062004C00 6500660074004D00 6100720067006900 6E000000FFFE0400
0020: 3000000054006100 6200430075007200 720065006E007400 0000FFFE0C004E00
0040: 61006D0065003100 0000540061006200 42006F0074007400 6F006D004D006100
0060: 7200670069006E00 0000FFFE04003000 0000540061006200 5000610067006500
0080: 43006F0075006E00 74000000FFFE0400 3100000054006100 62004C0061006200
00A0: 65006C0073000000 FFFE1C004C006100 620065006C003100 09004C0061006200
00C0: 65006C0032000000 5400610062004E00 61006D0065007300 0000FFFE18004E00
00E0: 61006D0065003100 09004E0061006D00 6500320000005400 6100620052006900
0100: 6700680074004D00 6100720067006900 6E000000FFFE0400 3000000054006100
0120: 6200440072006100 7700530074007900 6C0065000000FFFE 1600570069006E00
0140: 3900350053007400 79006C0065000000 5400610062004600 6F0072006D005000
0160: 6100670065007300 0000FFFE04000900 0000540061006200 54006F0070004D00
0180: 6100720067006900 6E000000FFFE0400 3000000054006100 62004F0072006900
01A0: 65006E0074006100 740069006F006E00 0000FFFE02000000 0000000000000000
01C0: 0000000000000000 000000000000
.enddata
END_OF_STRING
    @item2 = Sal::Item.new(@code2)
    @strprops2 = @item2.property_analyzer
    
    @code3 = <<END_OF_STRING
.head 3 +  Picture: picTabs
.data CLASSPROPS
0000: 5461624C6566744D 617267696E000200 3000005461624375 7272656E74000600
0020: 4E616D6531000054 6162426F74746F6D 4D617267696E0002 0030000054616250
0040: 616765436F756E74 0002003100005461 624C6162656C7300 0E004C6162656C31
0060: 094C6162656C3200 005461624E616D65 73000C004E616D65 31094E616D653200
0080: 0054616252696768 744D617267696E00 0200300000546162 447261775374796C
00A0: 65000B0057696E39 355374796C650000 546162466F726D50 6167657300020009
00C0: 0000546162546F70 4D617267696E0002 0030000000000000 0000000000000000
00E0: 0000000000000000
.enddata
END_OF_STRING
    @item3 = Sal::Item.new(@code3)
    @strprops3 = @item3.property_analyzer

    @code4 = <<END_OF_STRING
.head 1 +  Design-time Settings
.data VIEWINFO
0000: 6F00000001000000 FFFF01000D004347 5458566965775374 6174650400002000
0020: 0000000000A50000 002C000000020000 0003000000FFFFFF FFFFFFFFFFF8FFFF
0040: FFE1FFFFFFFFFFFF FF000000007C0200 004D010000010000 0001000000010000
0060: 000F4170706C6963 6174696F6E497465 6D00000000
.enddata
.data DT_MAKERUNDLG
0000: 0900001000000000 000F746573742E34 322E6578652E6578 650F746573742E34
0020: 322E6578652E646C 6C0F746573742E34 322E6578652E6170 6300000101010064
0040: 0000000000000100 0000000000000000 0F746573742E3432 2E6578652E617064
0060: 0F746573742E3432 2E6578652E646C6C 0F746573742E3432 2E6578652E617063
0080: 0000010101006400 00000F746573742E 34322E6578652E61 706C0F746573742E
00A0: 34322E6578652E64 6C6C0F746573742E 34322E6578652E61 7063000001010100
00C0: 640000000F746573 742E34322E657865 2E6578650F746573 742E34322E657865
00E0: 2E646C6C0F746573 742E34322E657865 2E61706300000101 0100640000000F74
0100: 6573742E34322E65 78652E646C6C0F74 6573742E34322E65 78652E646C6C0F74
0120: 6573742E34322E65 78652E6170630000 0101010064000000 0F746573742E3432
0140: 2E6578652E646C6C 0F746573742E3432 2E6578652E646C6C 0F746573742E3432
0160: 2E6578652E617063 0000010101006400 0000000000000000 06312E302E302E00
0180: 0005312E302E3000 0000000000000000 0000000000000001 0000000100000001
01A0: 0001000000000000 0000010000100000 0000000000000000 0000
.enddata
END_OF_STRING
    @item4 = Sal::Item.new(@code4)
    @strprops4 = @item4.property_analyzer

    @code5 = <<END_OF_STRING
.head 3 +  Picture: picTabs
.data CLASSPROPS
0000: 5461624C6566744D 617267696E000200 3000005461624375 7272656E74000600
0020: 4E616D6530000054 6162426F74746F6D 4D617267696E0002 0030000054616250
0040: 616765436F756E74 0002003100005461 624C6162656C7300 1C004C6162656C30
0060: 094C6162656C3109 4C6162656C32094C 6162656C33000054 61624E616D657300
0080: 18004E616D653009 4E616D6531094E61 6D6532094E616D65 3300005461625269
00A0: 6768744D61726769 6E00020030000054 6162447261775374 796C65000B005769
00C0: 6E39355374796C65 0000546162466F72 6D50616765730004 0009090900005461
00E0: 62546F704D617267 696E000200300000 0000000000000000 0000000000000000
0100: 00000000
.enddata
.data CLASSPROPSSIZE
0000: 0401
.enddata
.data INHERITPROPS
0000: 0100
.enddata
END_OF_STRING
    # @item5 = Sal::Item.new(@code5)
    # @strprops5 = @item5.property_analyzer
    # pp @strprops5
  end
  
end

MiniTest.autorun
