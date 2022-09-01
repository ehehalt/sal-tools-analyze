# coding: utf-8

require_relative "version.rb"
require_relative "errorlog.rb"

module Sal

	# The +Compiler+ class wraps the cbiXX.exe command line compiler
	# for an easy use. 
	# ----
	# Example:
	# 
	# compiler = Sal::Compiler.new(Sal::Version.new("4.2"))
	#
	# compiler.compile("foo.app")
	class Compiler
	
		# Switch to build an executable: -b
		SWITCH_BUILD_EXE = "-b"
		# Switch to build a dynamic library: -m
		SWITCH_BUILD_APD = "-m"

		# Extension for APP's (downcase)
		EXTNAME_APP = ".app"
		# Extension for APL's (downcase)
		EXTNAME_APL = ".apl"
		# Extension for APT's (downcase)
		EXTNAME_APT = ".apt"
		# Extension for APD's (downcase)
		EXTNAME_APD = ".apd"
		# Extension for EXE's (downcase)
		EXTNAME_EXE = ".exe"
		# Extension for ERR's (downcase)
		EXTNAME_ERR = ".err"

		attr_accessor :version

		# Initialize with a initialized Sal::Version object.
		# Alternatively with a version string. 
		# Then internaly would an Sal::Version object created.
		def initialize(version= nil)
			if version.nil?
				@version = nil
			elsif version.class == Version
				@version = version
			elsif version.class == String
				@version = Version.new(version)
			else
				@version = nil
			end
		end

		# Start the compiler and returns the pid of the compile process
		def compile(source, destination=nil)
			clean_err_file(source)
			command = get_compile_line(source, destination)
			pid = Process.spawn(command)
			Process.detach(pid)
			compile_is_started(source, pid)
			run_loop(source, pid)
			return get_err_log(source)
		end

		# Creates a compile line for a given source and optional destination
		# ----
		# Example: 
		#
		# compiler = Sal::Compiler.new(Sal::Version.new("4.2"))
		#
		# compiler.get_compile_line("foo.app") # => "cbi42.exe -b foo.app foo.exe" 
		def get_compile_line(source, destination=nil)
			destination = get_destination(source) if destination.nil?
			line = "#{@version.cbi_exe} #{get_compile_switch(source)} #{source} #{destination}"
		end

		# Returns the "-m" for an APD build or "-b" for an EXE build
		# ----
		# Example:
		#
		# compiler = Sal::Compiler.new(Sal::Version.new("4.2"))
		#
		# get_compile_switch("foo.apl") # => "-m"
		#
		# get_compile_switch("foo.app") # => "-b"
		def get_compile_switch(source)
			extname = File.extname(source).downcase
			return SWITCH_BUILD_EXE if extname == EXTNAME_APP
			return SWITCH_BUILD_APD 
		end

		# Returns the correspond destination for a given source file name
		# ----
		# Example:
		#
		# compiler = Sal::Compiler.new(Sal::Version.new("4.2"))
		#
		# get_destination("foo.apl") # => "foo.apd"
		def get_destination(source)
			extname = File.extname(source).downcase
			return File.basename(source, File.extname(source)) + (extname == EXTNAME_APP ? EXTNAME_EXE : EXTNAME_APD)
		end

		def get_err_file(source)
			extname = File.extname(source).downcase
			return File.basename(source, File.extname(source)) + EXTNAME_ERR
		end

		def get_err_log(source)
			errfile = get_err_file(source)
			log = ErrorLog.new(errfile, false)
		end

		def clean_err_file(source)
			errfile = get_err_file(source)
			File.delete(errfile) if File.exist? errfile
		end

		def compile_is_started(source, pid)
			# noting to do
		end

		def compile_is_running(source, pid)
			sleep 1
		end

	protected
	
		def run_loop(source, pid)
			t = Thread.new do
				ready = false
				while process_is_running(pid)
					compile_is_running(source, pid)
				end
				sleep 1
			end
			t.join
		end

		def process_is_running(pid)
			p = 0
			begin
		  		p = Process.kill( 0, pid )
			rescue
		  		p = 0
		  	end
		  	return p == 1 # true => process is running, false => process is ready
		end

	end

end

