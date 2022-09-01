# coding: utf-8

require "ostruct"
require "pp"

require_relative "externalfunction.rb"
require_relative "external.rb"
require_relative "format.rb"
require_relative "item.rb"
require_relative "library.rb"
require_relative "version.rb"
require_relative "constant.rb"
require_relative "stringproperties.rb"
require_relative "codehelper.rb"
require_relative "window.rb"

module Sal
  
  # CodeException for exceptions raised by the Code class
  class CodeException < RuntimeError
    attr :code
    def initialize(code)
      @code = code
    end
  end
  
  # Die Klasse Code repräsentiert den kompletten Quellcode einer Gupta Datei.
  # Man  kann sich über die items durch den Quellcode navigieren oder über
  # die libraries, external_libraries, usw. ...
  # Der Quellcode wird automatisch analysiert. Die tiefe Analyse kann beim initialize
  # über den zweiten (optionalen) Parameter auch ausgeschaltet werden um für
  # kleinere Tests (welches Dateiformat hat eine Datei, etc.) Zeit zu sparen.
  class Code
    
    # Initialize Code with filename
    # The sourcecode will read and the format and version are analysed
    # Optional parameter: parts (to set the parts to analyze)
    # * :all
    # * :ver
    # * :lib
    def initialize( filename, parts = :all )
      @filename = filename
      @code = CodeHelper.read_code_from_file @filename
      @parts = parts
      get_format_and_version_from_code
    end
    
    # Save the items of code back to disk
    # Without parameters, the original file will be overridden
    def save( new_filename = filename )
      save_code_to_file new_filename
    end
    
    # Save the items of code back to disk in a new file
    # Alias for save with a new filename
    def save_as( new_filename )
      save_code_to_file new_filename
    end
    
    attr_accessor :format, :filename, :version, :code
    
    # Getter für die Items (Lazy)
    def items
      get_items_from_code if @items.nil?
      @items
    end
	
  	# Constants werden erst analysiert, wenn sie benötigt werden	
  	def constants
  	  if @constants.nil?
  	    @constants = Array.new
  		  items.each do | item |
  		    if( item.level == 2 and item.code =~ /^Constants/ )
            item.childs.each do | child |
              if ( child.code =~ /^(System|User)/ )
                child.childs.each do | comment |
                  @constants << Constant.new( comment ) unless comment.commented?
  				      end
              end
            end
            break
          end
        end
      end
  	  return @constants
  	end
	
  	def constants_system
  	  constants.find_all { |  constant | constant.system? }
  	end
	
  	def constants_user
  	  constants.find_all { |  constant | constant.user? }
  	end
    
    # Libraries werden erst analysiert, wenn sie benötigt werden
    def libraries
      if @libraries.nil?
        @libraries = Array.new
        items.each do | item |
          if( item.level == 2 and !item.parent.nil? and item.parent.code =~ /Libraries/ )
            @libraries << Library.new(item) unless item.commented?
          end
        end
      end
      return @libraries
    end
    
	  # Fügt eine neue Library unter File Include ein
    def add_library(filename)
      # .head 1 +  Libraries
      # .head 2 -  File Include: qckttip.apl
      # .head 2 -  File Include: vt.apl
      items.each do | item |
        if( item.level == 1 and item.code =~ /Libraries/ )
          include_item = item.copy
          include_item.parent = item
          include_item.childs = []
          include_item.code = "File Include: #{filename}"
          include_item.level = item.level + 1
          @items.insert(@items.index(item) + 1, include_item)
          item.childs.insert(0, include_item)
          item.refresh_child_indicator
          include_item.refresh_child_indicator
          @libraries = nil
          return include_item
        end
      end
    end

    # Gibt das On SAM_AppStartup Item zurück, falls es existiert, ansonsten nil
    def app_startup_item
      # .head 2 +  Application Actions
      # .head 3 +  On SAM_AppStartup
      # .head 4 -  Set n1 = 1
      items.each do | item |
        if( item.level == 3 and item.code =~ /On SAM_AppStartup/ and not item.item_commented? )
          return item
        end
      end
      return nil
    end
  
    # Externals werden erst analysiert, wenn sie benötigt werden
    def externals
      if @externals.nil?
        @externals = Array.new
        items.each do | item |
          if( item.level == 3 and !item.parent.nil? and item.parent.code =~ /External Functions/ )
            @externals << External.new(item) unless item.commented?
          end
        end
      end
      return @externals
    end
    
    # Classes werden erst analysiert, wenn sie benötigt werden
    def classes
      if @classes.nil?
        @classes = []
        items.each do | item |
          if( item.level == 3 and !item.parent.nil? and item.parent.code.start_with?("Class Definitions") )
            @classes << Class.new(item) unless item.commented?
          end
        end
      end
      return @classes
    end
  
    # Fenster werden erst analysiert, wenn sie benötigt werden
    def windows
      if @windows.nil?
        wndw_items = items.select do | item | 
          item.level == 1 and 
          item.code =~ /((Form|Table) Window|Dialog Box):/ and
          !item.commented?
        end
        @windows = wndw_items.map { | item | Window.new( item ) }
      end
      return @windows
    end

    def has_quicktabs?
        qcktab_windows = windows.select { | window | window.pictab != nil }
        return qcktab_windows.count > 0
    end

    def to_s
      @file_name
    end
    
    # Gibt den aktuellen Code zurück, der in den Items hinterlegt ist
    def generated_code
      new_code = ""
      items.each do | item |
        new_code += item.line
      end
      new_code
    end
    
    def display(smart = true)
      disp  = "#{File.basename @filename} " 
      disp += (smart ? "- " : ":\n")
      disp += "Version = #{@version.td} "
      disp += (smart ? "- " : "\n")
      disp += "Format = #{@format}"
    end
    
    # Entfernt ein Item inklusive der Childs und deren Childs und ...
    def remove_item(item = nil)
      unless item.nil?
        item.parent.childs.delete(item) unless item.parent.nil?
        remove_items = item.childs_deep
        remove_items.each do | remove_item |
          @items.delete(remove_item)
        end
      end
    end
    
  private
    
    # Schreibt den Quellcode zurück auf die Festplatte
    def save_code_to_file(new_filename)
      fh = File.new(new_filename, "wb")
      fh.write( items.join )
      fh.close
    end
    
    # Ermittelt das Format (Normal, Text, Indented) und die Verison
    def get_format_and_version_from_code
      @format = Format::get_from_code @code
      @version = Version::from_code @code
    end
    
    # Erzeugt das @items Array und ruft je nach Format
    # die entsprechende Analyse Funktion auf.
    def get_items_from_code
      @items = []
      case format
      when Format::TEXT
        # _analyze_code_textmode
        analyze_items Format::TEXT
      when Format::INDENTED
        # Can't analyze indented mode code
        raise CodeException.new(self), "Can't analyze indented mode code"
      else
        # Can't analyze normal mode code
        raise CodeException.new(self), "Can't analyze normal mode code"
      end
    end
    
    # Analysiert den Quellcode
    # Parameter format ist eigentlich überflüssig, 
    # aber falls doch einmal indented analysiert werden sollte ...
    def analyze_items(format)
      vars = analyze_init(format)
      get_lines(vars)
      vars.lines.each do | line |
        if line.length > 0
          vars.line = line
          @items << get_item(vars)
        end
      end
    end
    
    # Initialisierung der Analyse. 
    # Es wird für den Datenaustausch ein OpenStruct
    # verwendet in dem die Informationen automatisch
    # zugeordnet werden können.
    def analyze_init(format)
      @items = Array.new
      vars = OpenStruct.new
      vars.counter = 0
      vars.levels = Hash.new
      vars.format = format
      return vars
    end
    
    # Der Quellcode wird in Zeilen gesplittet
    def get_lines(vars)
      vars.lines = []
      if(vars.format == Format::TEXT)
        code_split_text vars
      end
    end
    
    def code_split_text(vars)
      code = nil
      case @parts
      when :ver
        if @code =~ /(\.head 1 -  Outline Version.*)\.head 1 [+-]  Design-time Settings/m
          code = $1
        else
          code = @code
        end
      when :lib
        if @code =~ /(\.head 1 [+-]  Libraries.*)\.head 1 [+-]  Global Declarations/m
          code = $1
        else
          code = @code
        end
      else
        code = @code
      end
      lines = code.split(/^\.head/)
      lines.each do | line | 
        vars.lines << ".head#{line}" if line.length > 0
      end
      vars.lines
    end
    
    # Hieran ist noch zu arbeiten um auch Indented zu unterstützen
    def get_item(vars)
      # item = Item.new vars.line, vars.format
      if(vars.format == Format::TEXT)
        item = Item.new vars.line, vars.format, self
      end
      item.code_line_nr = vars.counter + 1
      vars.levels[item.level] = item
      if(item.level > 0 and vars.levels.count > 1)
        begin
          item.parent = vars.levels[item.level-1]
          item.parent.childs << item
        rescue
          warn "filename = #{@filename}"
          pp item
        end
      end
      vars.counter += 1 # Bei Textmode war vorher: item_counter = item_counter + code_line.split('\n').length
      item
    end  
    
  end
  
end
