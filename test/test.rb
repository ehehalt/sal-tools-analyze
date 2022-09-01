#!/usr/bin/env ruby
# coding: utf-8

require 'minitest/autorun'

require_relative "test_analyse.rb"
require_relative "test_class.rb"
require_relative "test_code.rb"
require_relative "test_codehelper.rb"
require_relative "test_codesearcher.rb"
require_relative "test_command.rb"
require_relative "test_compiler.rb"
require_relative "test_constant.rb"
require_relative "test_errorlog.rb"
require_relative "test_external.rb"
require_relative "test_externalfunction.rb"
require_relative "test_filesearcher.rb"
require_relative "test_format.rb"
require_relative "test_function.rb"
require_relative "test_item.rb"
require_relative "test_library.rb"
require_relative "test_parser.rb"
require_relative "test_quicktabsanalyse.rb"
require_relative "test_search.rb"
require_relative "test_searchresult.rb"
require_relative "test_searchpattern.rb"
require_relative "test_stringproperties.rb"
require_relative "test_version.rb"
require_relative "test_window.rb"

MiniTest.autorun
