#!/opt/local/bin/ruby
# coding: utf-8

require 'minitest/autorun'
require_relative '../lib/sal/codesearcher'
require_relative '../lib/sal/filesearcher'
require_relative '../lib/sal/searchpattern'

class TestCodeSearcher < MiniTest::Test

  def setup
    @filter = :filter
    @search = /search/
    @filesearcher = Sal::FileSearcher.new(@filter)
    @searchpattern = Sal::SearchPattern.new(@search)
  end
  
  def test_initialize_default
    cs = Sal::CodeSearcher.new
    assert_nil(cs.filesearcher)
    assert_equal([], cs.searchpattern)
  end
  
  def test_initialize_parameters
    cs = Sal::CodeSearcher.new(@filesearcher, [@searchpattern])
    assert_equal(@filesearcher, cs.filesearcher)
    assert_equal([@searchpattern], cs.searchpattern)
  end
  
  def test_filesearcher 
    cs = Sal::CodeSearcher.new
    cs.filesearcher = @filesearcher
    assert_equal(@filesearcher, cs.filesearcher)
    assert_equal(@filter, cs.filesearcher.filter)
  end
  
  def test_searchpattern  
    cs = Sal::CodeSearcher.new
    cs.searchpattern << @searchpattern
    assert_equal(1, cs.searchpattern.count)
    assert_equal(@searchpattern, cs.searchpattern[0])
    assert_equal(@search, cs.searchpattern[0].search)
  end
  
  def test_search
    sp0 = Sal::SearchPattern.new(/Outline/)
    sp1 = Sal::SearchPattern.new(/Classes/)
    fs = Sal::FileSearcher.new(/.52.text.ex.*\.app$/i)
    fs.dirs << "data"
    cs = Sal::CodeSearcher.new(fs, [sp0, sp1])
    
    assert_equal(2, cs.searchpattern.count)
    assert_equal(sp0, cs.searchpattern[0])
    assert_equal(sp1, cs.searchpattern[1])
    
    results = cs.search(true,false)
  end
  
  def test_destination
    sp = Sal::SearchPattern.new(/Outline/)
    fs = Sal::FileSearcher.new(/^test\.40\.text\.*/i)
    fs.dirs << "data"
    cs = Sal::CodeSearcher.new(fs, [sp])
    cs.destination = "./temp"
    assert_equal("./temp", cs.destination)
    cs.replace(true,false)
  end
  
  def test_indented
    sp = Sal::SearchPattern.new(/Outline/)
    fs = Sal::FileSearcher.new(/indented/i)
    fs.dirs << "data"
    cs = Sal::CodeSearcher.new(fs, [sp])
    
    assert_equal(5, fs.files.count)
    assert_raises(Sal::CodeException) do
      cs.search(true,false)
    end
  end

  def test_parts
    sp = Sal::SearchPattern.new(/Outline/)
    fs = Sal::FileSearcher.new(/.42.text.*\.app$/i)
    fs.dirs << "data"

    cs0 = Sal::CodeSearcher.new(fs, [sp])
    assert_equal(7, cs0.search(false, false).count)

    cs1 = Sal::CodeSearcher.new(fs, [sp], :ver)
    assert_equal(2, cs1.search(false, false).count)

    cs2 = Sal::CodeSearcher.new(fs, [sp], :lib)
    assert_equal(0, cs2.search(false, false).count)

    cs3 = Sal::CodeSearcher.new(fs, [sp], :all)
    assert_equal(7, cs3.search(false, false).count)
  end
  
end

MiniTest.autorun