#!/opt/local/bin/ruby
# coding: utf-8

require 'minitest/autorun'
require_relative '../lib/sal/filesearcher'

class TestFileSearcher < MiniTest::Test

  def setup
    @dircount = 1
    @filecount_err = 1
    @filecount_sal = 41
    @filecount_ges = @filecount_err + @filecount_sal
  end
  
  def test_initialize
    fs = Sal::FileSearcher.new
    fs.dirs << "data"
    assert_equal(@dircount, fs.dirs.count)
    assert_equal(@filecount_ges, fs.files.count)
    assert_equal(true, fs.recursive)
    assert_equal(/.*/, fs.filter)
  end
  
  def test_blacklistfilter
    fs = Sal::FileSearcher.new
    fs.dirs << "data"
    fs.blacklistfilter = /sql\.app$/
    assert_equal(@filecount_ges-1, fs.files.count)
  end
  
  def test_filter_1_klein
    fs = Sal::FileSearcher.new(/\.ap[p]$/i)
    fs.dirs << "data"
    assert_equal(@filecount_sal, fs.files.count)
    fs.recursive = false
    assert_equal(@filecount_sal, fs.files.count)
  end
  
    def test_filter_1_gross
    fs = Sal::FileSearcher.new(/\.AP[P]$/i)
    fs.dirs << "data"
    assert_equal(@filecount_sal, fs.files.count)
    fs.recursive = false
    assert_equal(@filecount_sal, fs.files.count)
  end
  
  def test_filter_2
    fs = Sal::FileSearcher.new(/^test.*/i)
    fs.dirs << "data"
    assert_equal(@filecount_ges, fs.files.count)
    fs.recursive = false
    assert_equal(@filecount_ges, fs.files.count)
  end
  
  def test_filter_3
    fs = Sal::FileSearcher.new(/test..1.*/i)
    fs.dirs << "data"
    assert_equal(14, fs.files.count)
    fs.recursive = false
    assert_equal(14, fs.files.count)
  end

  def test_filter_4
    fs = Sal::FileSearcher.new(/\.err$/i)
    fs.dirs << "data"
    assert_equal(@filecount_err, fs.files.count)
    fs.recursive = false
    assert_equal(@filecount_err, fs.files.count)
  end
  
  def test_recursive_on
    fs = Sal::FileSearcher.new(/\.ap[ltp]$/i)
    fs.dirs << Dir.pwd
    # fs.recursive = true # (default)
    assert_equal(true, fs.files.count > 0)
  end
  
  def test_recursive_off
    fs = Sal::FileSearcher.new(/\.ap[.]$/i)
    fs.dirs << Dir.pwd
    fs.recursive = false
    # warn Dir.pwd
    assert_equal(0, fs.files.count)
  end
end

MiniTest.autorun
