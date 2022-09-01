#!/opt/local/bin/ruby
# coding: utf-8

require 'minitest/autorun'
require 'pp'
require_relative '../lib/sal/search'
require_relative '../lib/sal/code'
require_relative '../lib/sal/item'

class TestSearch < MiniTest::Test
  
  def setup
    @lines = []
    @lines << ".head 0 +  Application Description: Version 1\r\n"
    @lines << ".head 1 +  ! Outline Version - 4.0.34\r\n"
    @lines << ".head 2 +  Set bCommented = TRUE\r\n"
    @lines << ".head 3 -  ! Set bCommented = TRUE\r\n"
	@lines << ".head 3 -   Set sSQL = \"SELECT * FROM\r\nTABLE1"
	@lines << <<END_OF_STRING
.head 6 -  Set sSlct = " select
  time
 , @decode ( '" || psColType || "'
  , 'VARCHAR', sold
  , 'CHAR', sold
  , 'INTEGER', @string( nold , 0 )
  , 'SMALLINT', @string( nold , 0 )
  , 'DATE', @datetochar( dold, 'DD.MM.YYYY' )
  , 'TIMESTMP', @datetochar( dold, 'DD.MM.YYYY HH:MI' )
  , 'TIME', @datetochar( dold, 'HH:MI' )
  , 'LONGVAR', '--long--'
  , 'FLOAT', '--float--'
  , 'DECIMAL', '--dec--'
  , '--def--' )
, @decode ( '" || psColType || "'
  , 'VARCHAR', snew
  , 'CHAR', snew
  , 'INTEGER', @string( nnew, 0 )
  , 'SMALLINT', @string( nnew , 0 )
  , 'DATE', @datetochar( dnew, 'DD.MM.YYYY' )
  , 'TIMESTMP', @datetochar( dnew, 'DD.MM.YYYY HH:MI' )
  , 'TIME', @datetochar( dnew, 'HH:MI' )
  , 'LONGVAR', '--long--'
  , 'FLOAT', '--float--'
  , 'DECIMAL', '--dec--'
  , '--def--' )
, bearbeiter
, @decode( bearbeiter, NULL, bagid, 0, bagid, @REPEAT('0', 4 - @LENGTH( BA_IDBEARBEITER ) ) ||  BA_IDBEARBEITER || '  ' ||
        @decode( ba_name || ba_vorname , NULL, 'k.A.', ' ', 'k.A.', ba_name || ', ' || ba_vorname ) )
, @decode( QUELLE, 30, 'IHRIS', 'PISA' )
into
  :tblHistory.col_datum
, :tblHistory.col_old
, :tblHistory.col_new
, :tblHistory.col_bearbeiter
, :tblHistory.col_bearbeitername
, :tblHistory.col_verursacher
from
  sysadm.cplogchange
, sysadm.uibearbeiter
where
  oaw	= '" || psOAW || "'
and
  table      = '" || psTabelle || "'
and
  column = '" || psSpalte || "'
and
  bearbeiter = ba_idbearbeiter (+)
order by
  time desc
END_OF_STRING
    
    @items = []
    parent = nil
    idx = 0
    @lines.each do | line |
      item = Sal::Item.new(line, Sal::Format::TEXT)
      item.parent = parent unless parent.nil?
      item.code_line_nr = idx
      parent.childs << item unless parent.nil?
      parent = item
      @items << item
      idx = idx + 1
    end    
  end
  
  def test_get_items
    search = Sal::Search.new(@items)
    assert_equal(6, search.get_items(Sal::SearchType::COMPLETE).count)
    assert_equal(0, search.get_items(Sal::SearchType::CODE).count)
    assert_equal(4, search.get_items(Sal::SearchType::COMMENTS).count)
  end
  
  def test_search
    search = Sal::Search.new(@items)
    
    search.add_search_pattern /Outline/
    search.add_search_pattern /Commented/
    search.add_search_pattern /Application/

    # Sal::SearchType::COMPLETE
    assert_equal(4, search.search.count)
    # Sal::SearchType::CODE
    search.pattern.map! { | p | p.type = Sal::SearchType::CODE; p }
    assert_equal(3, search.pattern.count)
    assert_equal(0, search.search.count)
    # Sal::SearchType::COMMENTS
    search.pattern.map! { | p | p.type = Sal::SearchType::COMMENTS; p }
    results = search.search
    assert_equal(3, results.count)
    results.each do | result |
      assert_equal(true, result.src.level != 2) # => 2 should not in the results
    end
  end
  
  # falls eine Zeile mehrere search_pattern erfüllt ...
  def test_search_multi_found
    search = Sal::Search.new(@items)
    
    search.add_search_pattern /Version/
    search.add_search_pattern /Application/
    search.add_search_pattern /Outline/
    
    assert_equal(2, search.search.count)
  end
  
  def test_search_multiline
    search = Sal::Search.new(@items)
    
    search.add_search_pattern /table1/i
	search.add_search_pattern /CPLOGCHANGE/i

    assert_equal(2, search.search.count)
  end
  
  def test_replace
    search = Sal::Search.new(@items)

    pattern = search.add_replace_pattern(/Version 1/, "Version 2")
    
    result = search.search
    
    assert_equal(1, result.count)
    assert_equal("Application Description: Version 2", result[0].dst.code)
    assert_equal(".head 0 +  Application Description: Version 2\r\n", result[0].dst.line)
  end
  
  def test_code
    code = Sal::Code.new("data/test.21.text.sql.app")
    search = Sal::Search.new(code.items)
    search.add_replace_pattern /Sql(Prepare|Commit)/, 'Fql\1', Sal::SearchType::CODE
    results = search.search
    assert_equal(2, results.count)
    rx = /(S|F)ql(Prepare|Commit)/
    nw = "@@@"
    results.each do | result |
      src = result.src.line.gsub(rx, nw).gsub(/^(.head . )-/,'\1+')
      dst = result.dst.line.gsub(rx, nw)
      assert_equal(src,dst)
      assert_equal(true, result.changed?)
    end
    # code.save_as "temp/test.21.text.sql.new.app"
  end
  
  def test_code_backup_comment
    code = Sal::Code.new("data/test.21.text.sql.app")
    items_count = code.items.count
    search = Sal::Search.new(code.items)
    pattern = search.add_replace_pattern /Sql(Prepare|Commit)/, 'Fql\1'
    pattern.backup_code = true
    pattern.comment = "Code changed by fecher Migration at "
    results = search.search
    assert_equal(items_count + (results.count*2), code.items.count)
    code.save_as "temp/test.21.text.sql.new.commented.backup.app"
  end
  
  def test_testmode
    code = Sal::Code.new("data/test.21.text.sql.app")
    items_count = code.items.count
    search = Sal::Search.new(code.items)
    pattern = search.add_replace_pattern /Sql(Prepare|Commit)/, 'Fql\1'
    pattern.backup_code = true
    pattern.comment = "Code changed by fecher Migration at "
    search.testmode = true
    results = search.search
    assert_equal(items_count, code.items.count)
    # result shows changes
    results.each do | result |
      assert_equal(result.dst.line, result.src.line)
    end
    # really nothing changed?
    rx = /Fql/
    code.items.each do | item |
      assert_nil(rx.match(item.code))
    end
  end
  
  def test_replace_insert_new_item
    code = Sal::Code.new("data/test.11.text.app")
    items_count = code.items.count
    search = Sal::Search.new(code.items)
    pattern = search.add_remove_pattern(/Default Classes/, Sal::SearchType::COMPLETE)
    pattern.backup_code = false
    results = search.search
    assert_equal(1, results.count)
  end
  
end

MiniTest.autorun

