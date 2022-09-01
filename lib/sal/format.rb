# coding: utf-8

require_relative 'codehelper'

module Sal
    
  # Ermittelt das Fileformat von Gupta Quellcode.
  # Das Ergebnis ist eine der Konstanten TEXT, NORMAL oder INDENTED.
  module Format

    TEXT = :t
    NORMAL = :n
    INDENTED = :i
    
    # Ermitteld das Fileformat für den im übergebenen String
    # vorhandenen Quellcode.
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
    
    # Ermitteld das Fileformat für die Datei deren Name übergeben
    # wird. Es wird die Datei gelesen und der Quellcode anschliessend
    # an die Funktion get_from_code weitergegeben.
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