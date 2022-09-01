# coding: utf-8

require 'pp'
require_relative "item.rb"

module Sal

  # Diese Klasse repräsentiert ein einzelnes Stringproperty
  # Zur Zeit gibt es nur lesenden Zugriff, da noch keine
  # Funktionaliät angedacht ist, String Properties verändert
  # zurückzuschreiben. 
  # Das Property Value enthält je nach Typ den entsprechenden
  # Datentyp.
  class StringProperty
    
    TYPE_STRING = :string
    TYPE_NUMBER = :number
    TYPE_ARRAY = :array
    TYPE_VALUE = :value
    
    def initialize(key, type = :string, value = nil)
      
      type = :array if value != nil and value.include? StringPropertyAnalyzer::SEP_ARRAY_STRING

      @key = key
      @type = type
      
      case type
      when :array
        @value = value.split(StringPropertyAnalyzer::SEP_ARRAY_STRING)
      when :number
        @value = value.to_i
      else
        @value = value
      end
    end
    
    def to_s
      "Key = '#{key}', Type = '#{type}', Value = '#{value.to_s}'"
    end
    
    attr_reader :key, :type, :value
    
  end
  
  # Die Klasse StringProperties dient der Analyse der StringProperties im Quellcode
  # Diese wird für zusätzliche Properties für Objekte verwendet, z. B. um GUI-Objekte
  # den QuickTabs zuzuordnen.
  #
  # VIEWINFO und DT_MAKERUNDLG befinden sich im Einbau (Alpha)
  class StringPropertyAnalyzer

    CLASSPROPSSIZE = "CLASSPROPSSIZE"
    CLASSPROPS = "CLASSPROPS"
    INHERITPROPS = "INHERITPROPS"
    CCDATA = "CCDATA"
    CCSIZE = "CCSIZE"
    VIEWINFO = "VIEWINFO"
    DT_MAKERUNDLG = "DT_MAKERUNDLG"
    
    # Separator zwischen Key und Nummernwert
    SEP_NUMBER_ASCII = 0x02
    SEP_NUMBER_UTF16 = 0x04
    SEPS_NUMBER = [SEP_NUMBER_ASCII, SEP_NUMBER_UTF16]
    
    # Separator zwischen Key und Stringwert
    SEP_STRING_ASCII = 0x06
    SEP_STRING_UTF16 = 0x0C # "\f"
    SEPS_STRING = [SEP_STRING_ASCII, SEP_STRING_UTF16]
    
    # Separator zwischen Key und einem Array von Stringwerten
    SEP_STRING_ARRAY_ASCII = 0x0E
    SEP_STRING_ARRAY_UTF16 = 0x1C
    SEPS_STRING_ARRAY = [SEP_STRING_ARRAY_ASCII, SEP_STRING_ARRAY_UTF16]
    
    # Separator zwischen Key und einer Konstanten
    SEP_VALUE_ASCII = 0x0B # "\v"
    SEP_VALUE_UTF16 = 0x16
    SEPS_VALUE = [SEP_VALUE_ASCII, SEP_VALUE_UTF16]

    # Seperator zwischem Make Infos (DT_MAKERUNDLG)
    SEP_MAKE_ASCII = 0x0F
    SEP_MAKE_UTF16 = 0x0F
    SEPS_MAKE = [SEP_MAKE_ASCII, SEP_MAKE_UTF16]

    # Die Trenner zwischen dem Key und dem Value
    SEPS_DATA = SEPS_NUMBER + SEPS_STRING + SEPS_STRING_ARRAY + SEPS_VALUE + SEPS_MAKE
    
    # Der Trenner zwischen mehreren Values innerhalb eines Arrays
    SEP_ARRAY = 0x09 # "\t"
    SEP_ARRAY_STRING = [SEP_ARRAY].pack('C*')
    
    # Die Trenner um die einzelnen Bestandteile
    SEP_BOUND_1 = 0x00
    SEP_BOUND_2 = 0xFEFF
    SEPS_BOUND = [SEP_BOUND_1, SEP_BOUND_2]
    
    # Initialize with the code behind data
    def initialize(code_behind_data)
      @data = code_behind_data
      if RUBY_PLATFORM =~ /darwin/
        # Für die Analyse unter dem Mac notwendig!
        @data = @data.gsub(/\r/,"")
      end
      
      # @group_names => Die Namen der einzelnen Datenblöcke (z.B. CLASSPROPSSIZE)
      @group_names = Hash.new
      # @group_data => Die Daten die zur jeweiligen Gruppe gehören
      @group_data = Hash.new
      @properties = []
      @utf16 = false
      analyze
    end
    
    attr_reader :data, :group_names, :group_data, :utf16
    attr_accessor :properties
    
    # Sind die StringProperties im UTF16-LE Format abgelegt?
    # Die Prüfung geschieht anhand des zweiten gespeicherten Bytes.
    # Ist dieses 00, so wird angenommen, dass es sich um UTF16-LE
    # Code handelt. Falls das irgendwann nicht funktioniert, sollte
    # dieser Teil überarbeitet werden
    def utf16?
      return @utf16
    end
    
    # names => CLASSPROPS
    # values => 0000: af05...
    
  private
  
    def analyze
      get_group_behind_groups
      data = get_property_data
      if(data[2..3] == "00")
	    utf16 = true
        words = analyze_property_data_utf16 data
      else
        words = analyze_property_data data
      end
      analyze_words words
    end
  
    def get_group_behind_groups
      group_name = nil
      group_value = nil
      @data.each_line  do | line |
		    next if line.strip.length == 0
        if line =~ /^\.data +(\w+)/
          group_name = $1
          group_value = ""
        elsif line =~ /^\.enddata/
          key = get_key_from_name(group_name)
          @group_names[key] = group_name
          @group_data[key] = group_value
          group_name = nil
        else
          group_value += line if not group_name.nil?
        end
      end
    end
    
    def get_property_data
      data = ""
      return "" unless @group_data.nil? or @group_data.keys.nil? or @group_data.keys.include? :props
      @group_data[:props].each_line do | line |
        data += line[6..-1].gsub(/(\W|\s)/, "")
      end
      return data
    end
    
    def analyze_property_data(data)     
      parts = []
      subparts = []
      split = false
      for i in 0..(data.length/2)
        byte = data[i*2..i*2+1]
        if byte.nil?
          next
        else
          byte = byte.to_i(16)
        end
        
        # subpart_i = convert_x_to_i(data[i*2], data[i*2+1])
        if SEPS_BOUND.include? byte
          unless split
            parts << subparts
            subparts = []
            split = true
          end
        else
          subparts << byte
          split = false
        end
      end
      parts << subparts
      wordparts = []
      parts.each do | part |
        wordparts << part.pack('C*')
      end
      
      wordparts
    end
    
    def analyze_property_data_utf16(data)
      
      parts = []
      subparts = []
      split = false
      for i in 0..(data.length/4)
        low = data[i*4..i*4+1]
        high = data[i*4+2..i*4+3]
        if high.nil? or low.nil?
          # warn "Nil Error: High = #{high}, Low = #{low}"
          next
        else
          char = (high + low).to_i(16)
        end
        
        # subpart_i = convert_x_to_i(data[i*2], data[i*2+1])
        if SEPS_BOUND.include? char
          unless split
            parts << subparts
            subparts = []
            split = true
          end
        else
          subparts << char
          split = false
        end
      end
      parts << subparts
      
      wordparts = []
      parts.each do | part |
        wordparts << part.pack('C*')
      end
      
      wordparts
    end
    
    def analyze_words(words)
      while words.length > 0
          
        key = words.shift
        sep = words.shift
        
        next if key.nil? or sep.nil? or key.length == 0

        sep_first_byte = sep.bytes.to_a[0]
        
        if(sep.length == 1 and SEPS_DATA.include? sep_first_byte)
          value = words.shift
        elsif(sep.length > 1)
          value = sep[1..-1]
          sep = sep[0]
        else
          # ?
        end

        type = get_type_from_separator sep_first_byte
        @properties << StringProperty.new(key, type, value)
      end
    end
    
    def get_key_from_name(name=nil)
      key = nil
      case name
      when CLASSPROPSSIZE
        key = :size
      when CLASSPROPS
        key = :props
      when INHERITPROPS
        key = :inherit
      when CCDATA
        key = :ccprops
      when CCSIZE
        key = :ccsize
      when VIEWINFO
        key = :viewinfo
      when DT_MAKERUNDLG
        key = :makerundlg
      end
    end
    
    def get_type_from_separator(separator=nil)
      type = nil
      if(SEPS_NUMBER.include? separator)
        type = :number
      elsif(SEPS_STRING.include? separator)
        type = :string
      elsif(SEPS_STRING_ARRAY.include? separator)
        type = :array
      elsif(SEPS_VALUE.include? separator)
        type = :value
      end
      return type
    end
    
  end
    
end  
    