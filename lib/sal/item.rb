# coding: utf-8

require_relative "format.rb"
require_relative "command.rb"
require_relative "stringproperties.rb"

module Sal
  
  # Die Klasse Item representiert eine Quellcode-Zeile eines Gupta-Quellcodes
  # Sie enthält Verweise auf den Parent und die Childs der Zeile. Dadurch kann
  # man sich durch den Quellcode navigieren.
  class Item
    include Format
    
    # Item erzeugen, optional kann das Format übergeben werden
    # andernfalls wird das Format anhand der Quellcodezeile ermittelt.
    # Bei der Initialisierung wird die Quellcodezeile analysiert.
    def initialize( line, file_format = nil, source_code = nil )
      @original = line
      @format = file_format.nil? ? Format.get_from_line(line) : file_format
      self.line = line
      @commented = false
      @parent = nil # Item
      @childs = Array.new # Items
      @child_indicator = "-"
      @analyzed = false
      @code_line_nr = -1
      @parts = []
      @property_analyzer = nil
      @source_code = source_code
      # path und path_part nur einmalig ermitteln (Performance!)
      @path = nil
      @path_part = nil
      analyze
    end
    
    # Ist das Item ein Kommentar?
    def item_commented?
      return @commented
    end
    
    # Ist das Item oder ein Parent des Items kommentiert?
    def commented?
      return true if item_commented?
      if parent.nil?
        return item_commented?
      else
        return parent.commented?
      end
    end
    
    # Aus dem Item einen Kommentar machen wenn es noch kein Kommentar ist
    def item_comment
      self.code = "! #{self.code}" unless item_commented?
      _analyze_commented
    end
    
    # Wurde der Quellcode schon analysiert?
    def analyzed?
      @analyzed
    end
    
    # Ist die Zeile eine Code Zeile (z.B. Set sTest = "Hallo")
    # Siehe auch command.rb!
    def is_code_line?
      Command.is_code_line? code
    end
    
    # Dient dem Setzen der Quellcodezeile. Daraufhin wird neu analysiert.
    def line=(value)
      @original = value
      analyze
    end
    
    # Rückgabe der Quellcodezeile. Sie wird dynamisch aus den Parts zusammengebaut
    def line
      case @format
       when TEXT
         @parts.join
       when INDENTED
         ("\t"*@parts[1])+@parts[5]+@parts[6]
       else
         raise "Sal::Item#line: Runs only for TEXT and INDENTED format!"             
       end
    end
    
    # Setzen des Outline Levels
    def level=(value)
      @parts[1] = value
    end
    
    # Rückgabe des Outline Levels
    def level
      @parts[1].to_i
    end
    
    # Setzen des Quellcodes der Zeile
    def code=(value)
      @parts[5] = value
    end
    
    # Rückgabe des Quellcodes der Zeile
    # Es fehlen alle Outline und .data Infos
    def code
      @parts[5]
    end
    
    # Gibt ein + zurück wenn das aktuelle Item Childs hat, ansonsten ein -
    def child_indicator
      @parts[3]
    end
    
    def refresh_child_indicator
      @parts[3] = (@childs != nil and @childs.length > 0 ? "+" : "-")
    end
    
    # Set the last carriage return line feed and (if exist) the binary data component
    def code_behind_data=(value)
      @parts[6] = value
      @property_analyzer = nil
    end
    
    # Read the last carriage return line feed and (if exist) the binary data component
    def code_behind_data
      @parts[6]
    end
    
    def property_analyzer
      if @property_analyzer.nil?
        @property_analyzer = StringPropertyAnalyzer.new(code_behind_data)
      end
      @property_analyzer
    end
    
    def properties
      # warn "Item::properties"
      property_analyzer.properties
    end

    def pictab?
      if code =~ /Picture: picTab/
        return true
      else
        return false
      end
    end

    def tab_names
      if @tab_names.nil?
        @tab_names = []
        if code_behind_data != nil and code_behind_data.length > 0
          prop = properties.select { | prop | prop.key == "TabChildNames" }.first
          if prop != nil
            if prop.type == :string
              @tab_names << prop.value
            elsif prop.type == :array
              @tab_names = prop.value
            end
          end
        end
      end
      @tab_names
    end
    
    attr_accessor :original, :parent, :childs, :format
    attr_accessor :tag, :code_line_nr, :parts
    attr_reader   :source_code
    
    # Gibt als String die Zeile zurück und nicht das Objekt
    def to_s
      line
    end
    
    # Gibt ein neues Objekt auf Basis des aktuellen Quellcodes von diesem Objekt zurück
    # Es beinhaltet aber keine Informationen über Parent, Childs, ...
    def copy
      Item.new(self.line)
    end
    
    # gibt die Childs und deren Childs usw. zurück
    def childs_deep
      deep = []
      deep << self
      childs.each do | child |
        deep.concat child.childs_deep
      end
      return deep
    end

    # alias für childs_deep
    def childs_flat
      childs_deep
    end
	
  	# Neues Child Item erzeugen und and die entsprechende Stelle als Child einbauen
  	# Per default an die erste Stelle. Gibt das neue Item nach Erstellung und Einfügen
  	# dann auch zurück.
  	def insert_new_child(code = "! new item", index=0)
  		line = ".head "
  		line += (level + 1).to_s
  		line += " -  "
  		line += code
  		line += "\r\n"
  		new_item = Item.new(line, Format::TEXT)
  		@childs.insert(index, new_item)
  		refresh_child_indicator
  		new_item
  	end

    # path_part wird nur einmalig ermittelt, da eine Verwendung
    # in der Quellcode
    def path_part
      if @path_part.nil?
        if /^(\w| )+:(.*)$/ =~ code 
          @path_part = $2.strip
        else
          @path_part = ""
        end
      end
      @path_part
    end

    def path
      if @path.nil?
        if parent.nil?
          @path = path_part
        else
          parent_path = parent.path
          if !commented?
            self_path_part = path_part
            if self_path_part.length > 0
              parent_path += "::"
            end
            parent_path += self_path_part
          end
          @path = parent_path
        end
      end
    @path
    end
      
  private
    
    # Analyse der Quellcodezeile
    def analyze
      if(!@analyzed)
        case @format
        when TEXT
          @analyzed = _analyze_textmode
        when INDENTED
          @analyzed = _analyze_indented
        else
          # Es kann nur Text oder Indented analysiert werden
          @analyzed = false                 
        end
      end
    end    
    
    # Analyse der Quellcodezeile (Textmode)
    def _analyze_textmode
      # re = /(^\.head )(\d+?)( )([+-])(  )(.*?)(\n*)$/
      # re = /(^\.head )(\d+?)( )([+-])(  )(.*?)(\r\n.*)/m
      re = /(^\.head )(\d+?)( )([+-])(  )(.*)/m
      md = re.match(@original)
      if md.nil?
        raise "Item::_analyze_textmode could not analyze level and code: #{@original}"
      else
        # 1 = Level, 3 = Child Indkator, 5 = Code
        # [1..-1] => md[0] ist der komplette String, der hier nicht benötigt wird
        @parts = md.to_a[1..-1]
        _analyze_textmode_split_code
        return _analyze_commented() 
      end
      return false
    end
    
    def _analyze_textmode_split_code
      temp = self.code
      new_code = ""
      new_data = ""
      temp.each_line do | line |
        if new_data.length > 0
          new_data += line
        else
          if line.start_with? ".data"
            new_data = line
          else
            new_code += line
          end
        end
      end
      if new_code.end_with? "\r\n"
        new_data = "\r\n" + new_data
        new_code = new_code[0..-3]
      end
      self.code = new_code
      self.code_behind_data = new_data
    end
    
    # Analyse der Quellcodezeile (Indented)
    def _analyze_indented
      if(@original =~ /(^\t*)(.*?)(\r\n.*)/m)
        @parts = []
        @parts[1] = $1.length
        @parts[5] = $2
        @parts[6] = $3
        return _analyze_commented()
      else
        raise "Item::_analyze_indented could not analyze level and code: #{self.line}"
      end
      return false
    end
    
    # Prüfung ob die Zeile kommentiert ist
    def _analyze_commented
      @commented = true if(self.code =~ /\A\s*?!/)
      return true
    end
  end
  
end
