# coding: utf-8

module Sal
  
  # CodeHelper Exception for exceptions raised by the Code class
  module CodeHelper

    # Gupta UTF16 LE Header Prüfung
    def CodeHelper.utf16le?(code)
      return (code[0..1] == (0xFF.chr + 0xFE.chr))
    end
    
    # Reads the file and use the filename
    def CodeHelper.read_code_from_file(filename)
      code = IO.binread filename
      if(CodeHelper.utf16le? code)
        code.encode!("UTF-8", "UTF-16")
        # code.encode!("windows-1250", "UTF-16")
      end
      return code
    end

    def CodeHelper.none_code_elements
      [
        "Outline Version",
        "Design-time Settings",
        "Default Classes",
        "Class:",
        "Property Template",
        "Window Defaults",
        "Formats",
        "Class DLL Name",
        "Title",
        "Icon File",
        "Accessories Enabled?",
        "Display Settings",
        "Visible?",
        "Application Description:",
        "Description:"
      ]
    end
    
  end
  
end
