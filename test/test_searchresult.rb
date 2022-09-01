#!/opt/local/bin/ruby
# coding: utf-8

require 'minitest/autorun'
require_relative '../lib/sal/search'

class TestSearchResult < MiniTest::Test
  
  def test_initialize_1
    result = Sal::SearchResult.new(1,2,true,true)
    assert_equal(1, result.src)
    assert_equal(1, result.source)
    
    assert_equal(2, result.dst)
    assert_equal(2, result.destination)
    
    assert_equal(true, result.changed)
    assert_equal(true, result.changed?)
    assert_equal(true, result.replaced)
    assert_equal(true, result.replaced?)
    
    assert_equal(true, result.testmode)
    assert_equal(true, result.testmode?)
  end
  
  def test_initialize_2
    result = Sal::SearchResult.new(1,2)
    
    assert_equal(false, result.testmode)
    assert_equal(false, result.testmode?)
  end
  
  def test_readonly
    result = Sal::SearchResult.new(1,2)
    begin
      result.src = 3
      assert_equal(true, false, "Source can't changed by user!")
    rescue
      assert_equal(true, true, "Source can't changed by user!")
    end
    begin
      result.dst = 3
      assert_equal(true, false, "Destination can't changed by user!")
    rescue
      assert_equal(true, true, "Destination can't changed by user!")
    end
    begin
      result.changed = false
      assert_equal(true, false, "Changed can't changed by user!")
    rescue
      assert_equal(true, true, "Changed can't changed by user!")
    end
  end
  
  def test_changed
    # mit Vorbelegung
    
    assert_equal(true, Sal::SearchResult.new(1,1,true).changed?)
    assert_equal(false, Sal::SearchResult.new(1,1,false).changed?)
    assert_equal(true, Sal::SearchResult.new(1,2,true).changed?)
    assert_equal(false, Sal::SearchResult.new(1,2,false).changed?)
    
    # ohne Vorbelegung
    
    # Numbers
    assert_equal(true, Sal::SearchResult.new(1,2).changed?)
    assert_equal(false, Sal::SearchResult.new(1,1).changed?)
    
    # Symbols
    assert_equal(false, Sal::SearchResult.new(:a, :a).changed?)
    assert_equal(true, Sal::SearchResult.new(:a, :b).changed?)
    
    # Strings
    assert_equal(false, Sal::SearchResult.new("a","a").changed?)
    assert_equal(true, Sal::SearchResult.new("a","b").changed?)
    
    # Objects
    i = Object.new
    j = Object.new
    assert_equal(false, Sal::SearchResult.new(i,i).changed?)
    assert_equal(true, Sal::SearchResult.new(i,j).changed?)    
  end

end

MiniTest.autorun