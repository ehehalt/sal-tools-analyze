#!/opt/local/bin/ruby
# coding: utf-8

require 'minitest/autorun'
require_relative '../lib/sal/parser'

class TestLexer < MiniTest::Test
  
  def setup
  	
  end

  def test_consume
    code = "Call SqlExists(\"select ...\")"
    lexer = Sal::LL1Lexer.new(code)
    
    assert_equal(code, lexer.input)
    assert_equal("C", lexer.current)
    assert_equal(Sal::LL1Lexer::EOF, lexer.last)
    assert_equal(0, lexer.index)

  	# assert_equal("joe", @parser.strip("joe"))
  end

  def test_is_operator
    lexer = Sal::CodeLexer.new("/")
    assert_equal("/", lexer.current)
    assert_equal(true, lexer.is_operator?)
    assert_equal(false, lexer.is_letter?)
  end

  def test_lexer
    tokens = Sal::CodeLexer.get_tokens("Call Test()")
    assert_equal(4, tokens.length)
    assert_equal("Call", tokens[0].text)
    assert_equal("Test", tokens[1].text)
    assert_equal("(", tokens[2].text)
    assert_equal(")", tokens[3].text)
    assert_equal(Sal::CodeLexer::NAME, tokens[0].type)
    assert_equal(Sal::CodeLexer::NAME, tokens[1].type)
    assert_equal(Sal::CodeLexer::LBRACK1, tokens[2].type)
    assert_equal(Sal::CodeLexer::RBRACK1, tokens[3].type)
  end

end

MiniTest.autorun