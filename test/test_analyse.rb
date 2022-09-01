#!/opt/local/bin/ruby
# coding: utf-8

require 'minitest/autorun'
require_relative '../lib/sal/analyse'

class TestAnalyse < MiniTest::Test

  def setup
    @filecount_sql = 1
    @filecount_ges = 41
  end

  def test_analyse
    analyse = Sal::Analyse.new
    
    assert_equal(false, analyse.file_searcher.nil?)
    assert_equal(false, analyse.search_pattern.nil?)
    assert_equal(0, analyse.search_pattern.count)
    assert_equal(true, analyse.files.count > 0)
  end

  def test_analyse_file_searcher
  	analyse = Sal::Analyse.new

    analyse.file_searcher.dirs << "data"
    assert_equal(@filecount_ges, analyse.files.count)

    analyse.file_searcher.filter = /test.42.*sqlfunctions\.app/
    assert_equal(@filecount_sql, analyse.files.count)
  end

  def test_analyse_search_pattern
    analyse = Sal::Analyse.new

    analyse.search_pattern << Sal::SearchPattern.new(/\bSqlError\b/, nil, Sal::SearchType::CODE, Sal::SearchFunction::SEARCH)
  	
  	assert_equal(1, analyse.search_pattern.count)
  end
  
  def test_analyse_analyse
  	analyse = Sal::Analyse.new

    analyse.file_searcher.dirs << "data"
    assert_equal(@filecount_ges, analyse.files.count)

	analyse.file_searcher.filter = /test.42.*sqlfunctions\.app/
	assert_equal(@filecount_sql, analyse.files.count)

    analyse.search_pattern << Sal::SearchPattern.new(/\bSqlExists\b/, nil, Sal::SearchType::CODE, Sal::SearchFunction::SEARCH)
    assert_equal(1, analyse.search_pattern.count)

    result = analyse.analyse
    assert_equal(1, result.count)

    statistic = analyse.statistic
    assert_equal(1, statistic.count)

    # pp statistic
  end

end

MiniTest.autorun