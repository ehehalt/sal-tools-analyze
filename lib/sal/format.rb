# coding: utf-8

require_relative 'codehelper'

module Sal
    
  # Get the file format from the Gupta source code
  # The result is TEXT, NORMAL or INDENTED.
  module Format

    TEXT = :t
    NORMAL = :n
    INDENTED = :i
    
    # Get the file format from the string code
    def Format.get_from_code( code )
      if(code =~ /Outline Version - \d\.\d\.(\d\d)/m)
        if(code =~ /^\.head/)
          return Format::TEXT
        else
          return Format::INDENTED
        end
      else
        return Format::NORMAL
      end
    end
    
    # Get the file format from the file
    def Format.get_from_file( filename )
      code = CodeHelper.read_code_from_file filename
      return get_from_code( code )
    end
        
    def Format.get_from_line( line )
      if(line.start_with? ".head")
        return Format::TEXT
      elsif(line.start_with? "Application Description" or line.start_with? "\t")
        return Format::INDENTED
      else
        return Format::NORMAL
      end
    end
    
  end

end