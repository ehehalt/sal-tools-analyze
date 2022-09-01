# coding: utf-8

require 'Win32API' if RUBY_PLATFORM =~ /mingw/ and RUBY_VERSION < '2.0.0'
require 'fiddle' if RUBY_PLATFORM =~ /mingw/ and RUBY_VERSION >= '2.0.0'
include Fiddle if RUBY_PLATFORM =~ /mingw/ and RUBY_VERSION >= '2.0.0'

module Sal

  class Cdk
  
    # Initialize with the tdversion
    def initialize(version)
      @cdkdll = version.cdk_dll
      define_externals
    end
    
    def convert_to_text(filename)
      result = false
      if @cdkdll.nil?
        warn "Sal::Cdk#convert_to_text: Platform '#{RUBY_PLATFORM}' not supported!"
      else
        if File.exist? filename
          outline = @cdk_load_app.Call( filename )
		      # outline = @cdk_load_app_suppress_includes.Call( filename, 0 )
		      warn "File '#{filename}' opended. Outline = #{outline}"
          result = @cdk_outline_save_as_text.Call( outline, filename, 0 )
          puts "File '#{filename}' converted. Result = #{result}"
        else
          raise "Sal::Cdk#convert_to_text: File '#{filename} not found!"
        end
      end
      return result
    end
    
  private
  
    def define_externals
      if @cdkdll.nil?
        warn "Sal::Cdk#define_externals: Platform '#{RUBY_PLATFORM}' not supported!"
      else
  	    begin
          if RUBY_VERSION < '2.0.0'
            define_externals_win32
		      else
            define_externals_fiddle
          end
        rescue LoadError => error
		      raise "Sal::Cdk#define_externals: DLL '#{@cdkdll} not found!"
		    end
      end
    end

    def define_externals_win32
      @cdk_load_app = Win32API.new(@cdkdll, "CDKLoadApp", ['P'],'L' )
      # @cdk_load_app_suppress_includes = Win32API.new(@cdkdll, "CDKLoadAppSuppressIncludes", ['P', 'L'],'L' )
      @cdk_outline_save_as_text = Win32API.new(@cdkdll, "CDKOutlineSaveAsText", ['L','P','L'],'L')
    end

    def define_externals_fiddle
      cdk_lib = Fiddle.dlopen(@cdkdll)

      @cdk_load_app = Fiddle::Function.new(cdk_lib["CDKLoadApp"],[TYPE_VOIDP], TYPE_LONG)
      def @cdk_load_app.Call(filename)
        self.call(filename)
      end

      @cdk_outline_save_as_text = Fiddle::Function.new(cdk_lib["CDKOutlineSaveAsText"], [TYPE_LONG, TYPE_VOIDP, TYPE_LONG], TYPE_LONG)
      def @cdk_outline_save_as_text.Call(outline, filename, number)
        self.call(outline, filename, number)
      end
    end
  
  end
    
end  
    