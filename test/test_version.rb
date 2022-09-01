#!/opt/local/bin/ruby
# coding: utf-8

require 'minitest/autorun'
require_relative '../lib/sal/version'

class TestVersion < MiniTest::Test
  
  def test_file_to_td
    
    # unit tests für versionen von 0 bis 100
    i = 0
    test_empty = Array.new
    test_empty += (0..25).to_a
    test_empty += [29, 30, 33, 36, 38, 40, 42, 43, 44, 45, 46, 49, 51]
    test_empty += (58..100).to_a
    test_empty.each do | test | 
      i += 1
      begin
        Sal::Version.file_to_td(test)
        assert false, "test = #{test} fails"
      rescue RuntimeError
        assert true, "test = #{test} success"
      end
    end
    
    assert_equal("1.1", Sal::Version.file_to_td(26))
    assert_equal("1.5", Sal::Version.file_to_td(27))
    # assert_equal("2.0", Sal::Version.file_to_td(28))
    assert_equal("2.1", Sal::Version.file_to_td(28))
    assert_equal("3.0", Sal::Version.file_to_td(31))
    assert_equal("3.1", Sal::Version.file_to_td(32))
    assert_equal("4.0", Sal::Version.file_to_td(34))
    assert_equal("4.1", Sal::Version.file_to_td(35))
	  # assert_equal( "4.2", Sal::Version.file_to_td(35))
    # assert_equal("5.0", Sal::Version.file_to_td(37))
    assert_equal("5.1", Sal::Version.file_to_td(37))
    assert_equal("5.2", Sal::Version.file_to_td(39))
    assert_equal("6.0", Sal::Version.file_to_td(41))
    assert_equal("6.1", Sal::Version.file_to_td(47))
    assert_equal("6.2", Sal::Version.file_to_td(50))
    assert_equal("6.3", Sal::Version.file_to_td(52))
    assert_equal("7.0", Sal::Version.file_to_td(53))
    assert_equal("7.1", Sal::Version.file_to_td(54))
    assert_equal("7.2", Sal::Version.file_to_td(55))
    assert_equal("7.3", Sal::Version.file_to_td(56))
    assert_equal("7.4", Sal::Version.file_to_td(57))
	
  end
  
  def test_td_to_file
    assert_equal(26, Sal::Version.td_to_file("1.1"))
    assert_equal(27, Sal::Version.td_to_file("1.5"))
    assert_equal(28, Sal::Version.td_to_file("2.0"))
    assert_equal(28, Sal::Version.td_to_file("2.1"))
    assert_equal(31, Sal::Version.td_to_file("3.0"))
    assert_equal(32, Sal::Version.td_to_file("3.1"))
    assert_equal(34, Sal::Version.td_to_file("4.0"))
    assert_equal(35, Sal::Version.td_to_file("4.1"))
    assert_equal(35, Sal::Version.td_to_file("4.2"))
    assert_equal(37, Sal::Version.td_to_file("5.0"))
    assert_equal(37, Sal::Version.td_to_file("5.1"))
    assert_equal(39, Sal::Version.td_to_file("5.2"))
    assert_equal(41, Sal::Version.td_to_file("6.0"))
    assert_equal(47, Sal::Version.td_to_file("6.1"))
    assert_equal(50, Sal::Version.td_to_file("6.2"))
    assert_equal(52, Sal::Version.td_to_file("6.3"))
    assert_equal(53, Sal::Version.td_to_file("7.0"))
    assert_equal(54, Sal::Version.td_to_file("7.1"))
    assert_equal(55, Sal::Version.td_to_file("7.2"))
    assert_equal(56, Sal::Version.td_to_file("7.3"))
    assert_equal(57, Sal::Version.td_to_file("7.4"))
  end
  
  def test_initialize
    assert_equal(26, Sal::Version.new("1.1").file)
    assert_equal("1.1", Sal::Version.new(26).td)
  end
  
  def test_from_code
    assert_equal(26, Sal::Version.from_code(".head 1 -  Outline Version - 4.0.26").file)
    assert_equal(26, Sal::Version.from_code("Outline Version - 4.0.26").file)
  end
  
  def test_to_code
    version = Sal::Version.new(27)
    assert_equal("Outline Version - 4.0.27", version.to_code("Outline Version - 4.0.26"))
  end

  def test_cbi_exe
    version = Sal::Version.new("4.1")
    assert_equal("cbi41.exe", version.cbi_exe)

    version = Sal::Version.new(35)
    assert_equal("cbi41.exe", version.cbi_exe)
  end

  def test_cdk_dll
    version = Sal::Version.new("4.1")
    assert_equal("cdki41.dll", version.cdk_dll)

    version = Sal::Version.new(35)
    assert_equal("cdki41.dll", version.cdk_dll)
  end
	
end

MiniTest.autorun