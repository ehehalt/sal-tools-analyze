#!/opt/local/bin/ruby
# coding: utf-8

require 'minitest/autorun'
require_relative '../lib/sal/compiler'
require_relative '../lib/sal/version'

class TestCompiler < MiniTest::Test
  
  def test_initialize
    compiler = Sal::Compiler.new()
    assert_equal(nil, compiler.version)

    compiler = Sal::Compiler.new("1.1")
    assert_equal("1.1", compiler.version.td)

    compiler = Sal::Compiler.new(Sal::Version.new("1.1"))
    assert_equal("1.1", compiler.version.td)

  end

  def test_get_compile_switch
  	compiler = Sal::Compiler.new(Sal::Version.new("4.2"))

    assert_equal(Sal::Compiler::SWITCH_BUILD_EXE, compiler.get_compile_switch("test.app"))
    assert_equal(Sal::Compiler::SWITCH_BUILD_EXE, compiler.get_compile_switch("test.APP"))
    assert_equal(Sal::Compiler::SWITCH_BUILD_APD, compiler.get_compile_switch("test.apl"))
    assert_equal(Sal::Compiler::SWITCH_BUILD_APD, compiler.get_compile_switch("test.apt"))
  end

  def test_get_destination
  	compiler = Sal::Compiler.new(Sal::Version.new("4.2"))

  	assert_equal("test.exe", compiler.get_destination("test.app"))
  	assert_equal("TEST.exe", compiler.get_destination("TEST.APP"))

  	assert_equal("test.apd", compiler.get_destination("test.apl"))
  	assert_equal("TEST.apd", compiler.get_destination("TEST.APT"))
  end
  
  def test_get_compile_line
  	compiler = Sal::Compiler.new(Sal::Version.new("4.2"))

  	assert_equal("cbi42.exe -b foo.app foo.exe", compiler.get_compile_line("foo.app"))
  	assert_equal("cbi42.exe -b foo.app bar.exe", compiler.get_compile_line("foo.app", "bar.exe"))

  	assert_equal("cbi42.exe -m foo.apl foo.apd", compiler.get_compile_line("foo.apl"))
  	assert_equal("cbi42.exe -m foo.apt BAR.APD", compiler.get_compile_line("foo.apt", "BAR.APD"))
  end

  def test_get_err_file
    compiler = Sal::Compiler.new(Sal::Version.new("4.2"))

    assert_equal("foo.err", compiler.get_err_file("foo.apl"))
  end

end

MiniTest.autorun