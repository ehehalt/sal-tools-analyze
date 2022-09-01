# coding: utf-8

require_relative "format"

module Sal

  # Die Version Klasse beinhaltet die Information zur Team Developer Version und
  # zur entsprechenden File Version. Sie analysiert anhand des Codes auch die
  # entsprechenden Versionen.
  # Zusätzlich kann die File Version im Quellcode auch verändert. werden.
  class Version
    
    # Die Version kann mit der Fileversion oder der TD Version initialisiert
    # werden. Das initialize analysiert den Punkt in der TD Version um zu erkennen
    # mit welcher Version es zu tun hat.
    def initialize(version)
      if(version.to_s.include? ".")
        @td = version
        @file = Version.td_to_file @td
      else
        @file = version
        @td = Version.file_to_td @file
      end
    end
    
    attr_accessor :td, :file
    
    # Die Version anhand des Codes ermitteln und ein vorbelegtes Version-Objekt
    # zurückgeben. Siehe auch Version.from_file
    def Version.from_code(code)
      Version.new(self.file_version_from_code(code))
    end
    
    # Die Version anhand der Datei ermitteln und ein vorbelegtes Version-Objekt
    # zurückgeben. Siehe auch Version.from_code
    def Version.from_file(filename)
      code = CodeHelper.read_code_from_file filename
      Version.from_code code
    end
    
    def cbi_exe
      exe = "cbi#{td.sub(/\./,"")}.exe"
    end

    def cdk_dll
      dll = "cdki#{td.sub(/\./,"")}.dll"
    end

    # Setzt die Fileversion der Datei
    #
    # Es wird ansonsten im Quellcode nichts geändert, so dass der Quellcode
    # dann vom Quellcode geöffnet werden kann dessen Version eingestellt ist,
    # es aber erst einmal Fehler geben kann, weil Elemente enthalten sind,
    # welche vom entsprechenden Team Developer nicht unterstützt werden.
    def to_file(filename) 
      code = IO.binread filename
      code = to_code(code, @file)
      f = File.new(filename, "w")
      f.syswrite code
      f.close
    end
    
    # Ändert im übergebenen Quellcode die Fileversion in die übergebene
    # Fileversion um.
    def to_code(code)
      format = Format.get_from_code code
      if format == Format::NORMAL
        raise "Version.set_to_code: Code length to small!" if code.length < 5
        code[4] = case file
        when 26
          "\xfa"  # Team Developer 1.1
        when 27
          "\xfb"  # Team Developer 1.5
        when 28
          "\xfc"  # Team Developer 2.0/2.1
        when 31
          "\xff"  # Team Developer 3.0
        when 32
          "\x00"  # Team Developer 3.1
        when 34
          "\x02"  # Team Developer 4.0
        when 35
          "\x03"  # Team Developer 4.1/4.2
        when 37
          "\x06"  # Team Developer 5.0/5.1
        when 39
          "\x09"  # Team Developer 5.2
        when 41
          "\x0b"  # Team Developer 6.0
		    when 47
          "\x11"  # Team Developer 6.1
        when 50
          "\x14"  # Team Developer 6.2
        when 52
          "\x16"  # Team Developer 6.3
        when 53
          "\x17"  # Team developer 7.0
        when 54
          "\x18"  # Team developer 7.1
        when 55
          "\x19"  # Team developer 7.2
        when 56
          "\x1A"  # Team developer 7.3
        when 57
          "\x1B"  # Team developer 7.4
        else
          raise "Version.to_code: Version not settable: #{@file}/#{@td}"
        end
      else
        code.sub!(/(Outline Version - \d\.\d\.)(\d\d)/m, '\1' + file.to_s)
      end
      code
    end
    
    # Die TD Version in die entsprechende File Version umwandeln.
    def Version.td_to_file(td_version)
      case td_version
      when "1.1"
        26
      when "1.5"
        27
      when "2.0"
        28
      when "2.1"
        28
      when "3.0"
        31
      when "3.1"
        32
      when "4.0"
        34
      when "4.1"
        35
      when "4.2"
        35
      when "5.0"
        37
      when "5.1"
        37
      when "5.2"
        39
      when "6.0"
        41
      when "6.1"
        47
      when "6.2"
        50
      when "6.3"
        52
      when "7.0"
        53
      when "7.1"
        54
      when "7.2"
        55
      when "7.3"
        56
      when "7.4"
        57
      else
        raise "Version:td_to_file(#{td_version}): Version not analyzable."
      end
    end
    
    # Die File Version in die ensprechende TD Version umwandeln
    def Version.file_to_td(file_version)
      case file_version
      when 26
        "1.1"
      when 27
        "1.5"
      when 28
        "2.1" # "2.0"
      when 31
        "3.0"
      when 32
        "3.1"
      when 34
        "4.0"
      when 35
        "4.1" # "4.2"
      when 37
        "5.1" # "5.0"
      when 39
        "5.2"
      when 41
        "6.0"
      when 47
        "6.1"
      when 50
        "6.2"
      when 52
        "6.3"
      when 53
        "7.0"
      when 54
        "7.1"
      when 55
        "7.2"
      when 56
        "7.3"
      when 57
        "7.4"
      else
        raise "Version:file_to_td(#{file_version}): Version not analyzable."
      end
    end
    
  private
  
    # Die File Version anhand des Codes ermitteln
    def Version.file_version_from_code(code)
      if(code =~ /Outline Version - \d\.\d\.(\d\d)/m)
        $1.to_i
      else
        zeichen = code[4]
        case zeichen
        when "\xfa"   # Team Developer 1.1
          26
        when "\xfb"   # Team Developer 1.5
          27
        when "\xfc"   # Team Developer 2.0/2.1
          28
        when "\xff"   # Team Developer 3.0
          31
        when "\x00"   # Team Developer 3.1
          32
        when "\x02"   # Team Developer 4.0
          34
        when "\x03"   # Team Developer 4.1/4.2
          35
        when "\x06"   # Team Developer 5.0/5.1
          37
        when "\x09"   # Team Developer 5.2
          39
        when "\x0b"   # Team Developer 6.0
          41  
        when "\x11"   # Team Developer 6.1
          47
        when "\x14"   # Team Developer 6.2
          50
        when "\x16"   # Team Developer 6.3
          52
        when "\x16"   # Team Developer 7.0
          53
        when "\x16"   # Team Developer 7.1
          54
        when "\x16"   # Team Developer 7.2
          55
        when "\x16"   # Team Developer 7.3
          56
        when "\x16"   # Team Developer 7.4
          57
        else
          byte = zeichen.bytes.to_a[0].to_s(16)
          raise "Version.get_from_code: Normal Mode: Version not analyzable, zeichen = #{byte}"
        end
      end
    end
    
  end

end