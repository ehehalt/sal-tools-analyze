# coding: utf-8

module Sal

	class ErrorLog

		attr_reader :filename

		def initialize(filename, lazy=true)
			@filename = filename
			@errors = nil
			unless lazy
				analyze_file(filename)
			end
		end

		def errors
			analyze_file(@filename) if @errors.nil?
			@errors
		end

		def nfr_count
			analyze_file(@filename) if @nfr_count.nil?
			@nfr_count
		end

	private

		def analyze_file(filename)
			@errors = []
			@nfr_count = 0
			return unless File.exist? filename
			File.open(filename, "r") do | errorlog |

				error = false
				line1 = nil
				line2 = nil
				
				errorlog.each_line do | line |
					if error == false and line.start_with? "Source:"
						error = true
						line1 = line
					elsif error == true and line.start_with? "\t"
						error = false
						line2 = line
						@errors << Error.new(line1, line2)
					elsif error == false and line.start_with? "Please be reminded"
						@nfr_count += 1
					end
				end
			end
		end
	end

	class Error

		attr_reader :line1, :line2

		def initialize(line1, line2 = "")
			@line1 = line1
			@line2 = line2
		end

		def code
			analyze if @code.nil?
			@code
		end

		def position
			analyze if @position.nil?
			@position
		end

		def message
			analyze if @message.nil?
			@message
		end

	private

		def analyze
			@line1 =~ /^Source:\s*(.*?)\s*$/
			@code = $1.chomp

			@line2 =~ /^\s*Position:\s*(.*?)\s*Error:\s*(.*?)\s*$/
			@position = $1.chomp.to_i
			@message = $2.chomp
		end

	end
	
end