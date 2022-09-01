# coding: utf-8


require_relative 'codesearcher'
require_relative 'filesearcher'
require_relative 'searchpattern'

module Sal

	class AnalyseResult
		
		attr_accessor :search_pattern, :results

		def initialize(search_pattern)
			@search_pattern = search_pattern
			@results = []
		end
	end
	
	class Analyse

		attr_reader :code_searcher
		attr_accessor :file_searcher, :search_pattern

		def initialize(file_searcher = nil, search_pattern = nil)
			@file_searcher = file_searcher.nil? ? FileSearcher.new(/.*\.ap[lpt]$/i) : file_searcher
			@search_pattern = search_pattern.nil? ? Array.new : search_pattern
		end

		def files
			@file_searcher.files
		end

		def analyse(parts=:all, output=false)
			code_searcher = CodeSearcher.new(file_searcher, search_pattern)
			search_results = code_searcher.search(false, output)
			results = []
			search_results.each do | search_result |
				results << search_result.src.code
			end
			results
		end

		def statistic(parts=:all, output=false)
			results = analyse(parts, output)
			statistics = []
			@search_pattern.each do | pattern |
				statistic = AnalyseResult.new(pattern)
				results.each do | result |
					statistic.results << result if result =~ pattern.search
				end
				statistics << statistic
			end
			statistics
		end
	end

end