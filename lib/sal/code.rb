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
  
  # The class Code represents the complete sourcecode of a Gupta file.
  # The sourcecode is automatically analyzed. The deep analyze could be
  # deactivated with the second (optional) parameter, to save time in 
  # smaller tests (analyze the file format, ...).
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
	
  	# Constants analyzed lazy
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
    
    # Libraries analyzed lazy
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
    
	  # Add a new library under "File Include"
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

    # Returns the "On SAM_AppStartup Item" back, if it exists, otherwise returns nil
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
  
    # Externals analyzed lazy
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
    
    # Classes analyzed lazy
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
  
    # Windows analyzed lazy
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
    
    # Returns the current code from the items
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
    
    # Removes an item with his childs
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
    
    # Writes the source code to a file.
    def save_code_to_file(new_filename)
      fh = File.new(new_filename, "wb")
      fh.write( items.join )
      fh.close
    end
    
    # Analyze the format (Normal, Text, Indented) and the version of the file
    def get_format_and_version_from_code
      @format = Format::get_from_code @code
      @version = Version::from_code @code
    end
    
    # Creates the @items array and analyze it
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
    
    # Analyze the source code
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
    
    # Analyze init, uses for data transfer an OpenStruct object.
    def analyze_init(format)
      @items = Array.new
      vars = OpenStruct.new
      vars.counter = 0
      vars.levels = Hash.new
      vars.format = format
      return vars
    end
    
    # Split the source code in code lines
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
    
    # TODO: Support Indented code
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
      vars.counter += 1 # In textmode was: item_counter = item_counter + code_line.split('\n').length
      item
    end  
    
  end
  
end
