# coding: utf-8

require_relative "format"

module Sal

  # The version class analyze the Team Developer version of the file.
  # It converts file versions to Team Developer version and vice versa.
  # The class could additionaly change a version in a given source file.
  class Version
    
    # The version could be initialized with the file version or the td version.
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
    
    # Get the version from the code and return a version object.
    def Version.from_code(code)
      Version.new(self.file_version_from_code(code))
    end
    
    # Get the version from the file and return a version object.
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

    # Set the fileversion of the file
    # Nothing else would be changed in the code.
    def to_file(filename) 
      code = IO.binread filename
      code = to_code(code, @file)
      f = File.new(filename, "w")
      f.syswrite code
      f.close
    end
    
    # Change the file version in the new one in the source code
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
    
    # Convert the td version to the file version
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
    
    # Convert the file version to the td version
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
  
    # Analyze the file version from the code
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