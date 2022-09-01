#!/opt/local/bin/ruby
# coding: utf-8

require 'minitest/autorun'
require_relative '../lib/sal/searchpattern'

class TestSearchPattern < MiniTest::Test
  
  def setup
    @search = /search/
    @replace = :replace.to_s
    @comment = :comment.to_s
    @st_complete = Sal::SearchType::COMPLETE
    @st_code = Sal::SearchType::CODE
    @st_comments = Sal::SearchType::COMMENTS
    @func_replace = Sal::SearchFunction::REPLACE
    @func_delete = Sal::SearchFunction::REMOVE
  end
  
  def test_initialize_defaults
    pattern = Sal::SearchPattern.new(@search)
    
    assert_equal(@search, pattern.search)
    assert_equal(nil, pattern.replace)
    assert_equal(nil, pattern.comment)
    assert_equal(true, pattern.search_in_code)
    assert_equal(true, pattern.search_in_comments)
    assert_equal(@st_complete, pattern.type)
    assert_equal(true, pattern.backup_code)
    assert_equal(@func_replace, pattern.function)
  end
  
  def test_initialize_type_complete
    pattern = Sal::SearchPattern.new(@search, @replace)
    pattern.comment = @comment
    pattern.backup_code = false
    
    assert_equal(@search, pattern.search)
    assert_equal(@replace, pattern.replace)
    assert_equal(@comment, pattern.comment)
    assert_equal(true, pattern.search_in_code)
    assert_equal(true, pattern.search_in_comments)
    assert_equal(@st_complete, pattern.type)
    assert_equal(false, pattern.backup_code)
  end
  
  def test_initialize_type_code
    pattern = Sal::SearchPattern.new(@search, nil, @st_code)
    
    assert_equal(@search, pattern.search)
    assert_equal(nil, pattern.replace)
    assert_equal(nil, pattern.comment)
    assert_equal(true, pattern.search_in_code)
    assert_equal(false, pattern.search_in_comments)
    assert_equal(@st_code, pattern.type)
  end
  
  def test_initialize_type_comments
    pattern = Sal::SearchPattern.new(@search, nil, @st_comments)
    
    assert_equal(@search, pattern.search)
    assert_equal(nil, pattern.replace)
    assert_equal(nil, pattern.comment)
    assert_equal(false, pattern.search_in_code)
    assert_equal(true, pattern.search_in_comments)
    assert_equal(@st_comments, pattern.type)
  end
  
  def test_initialize_function_search
    pattern = Sal::SearchPattern.new(@search, nil, @st_comments, @func_search)
    
    assert_equal(@search, pattern.search)
    assert_equal(nil, pattern.replace)
    assert_equal(nil, pattern.comment)
    assert_equal(false, pattern.search_in_code)
    assert_equal(true, pattern.search_in_comments)
    assert_equal(@st_comments, pattern.type)
    assert_equal(@func_search, pattern.function)
  end
  
  def test_initialize_function_delete
    pattern = Sal::SearchPattern.new(@search, nil, @st_comments, @func_search)
    
    assert_equal(@search, pattern.search)
    assert_equal(nil, pattern.replace)
    assert_equal(nil, pattern.comment)
    assert_equal(false, pattern.search_in_code)
    assert_equal(true, pattern.search_in_comments)
    assert_equal(@st_comments, pattern.type)
    assert_equal(@func_search, pattern.function)
  end
  
end

MiniTest.autorun