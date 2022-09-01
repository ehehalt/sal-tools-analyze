# coding: utf-8

require_relative 'filesearcher'
require_relative 'searchpattern'
require_relative 'code'

module Sal
  
  class CodeSearcher
    
    # Optional parameter: parts (to set the parts to analyze)
    # * :all
    # * :ver
    # * :lib
    def initialize(filesearcher = nil, searchpattern = [], parts = :all)
      @filesearcher = filesearcher
      @searchpattern = searchpattern
      @destination = nil
      @fileinclude = nil
      @fileinclude_comment = nil
      @fileinclude_allways = false
      @app_startup_code = []
      @app_startup_code_comment = nil
      @parts = parts
    end
    
    # destination = destination directory, wenn nicht angegeben, werden die dateien überschrieben
    attr_accessor :filesearcher, :searchpattern, :destination
    # fileinclude_allways == true bedeutet: Egal ob in der Datei ein Searchpattern funktioniert hat oder nicht: File Inlcudes werden eingebaut
    attr_accessor :fileinclude, :fileinclude_comment, :fileinclude_allways
    attr_accessor :app_startup_code, :app_startup_code_comment
    
    def destination=(value)
      if File.exist? value and File.directory? value
        @destination = value
      else
        raise "Directory '#{value}' not found or not a directory."
      end
    end
    
    def search(testmode=false, output=true)
      options = [:s]
      options << :t if testmode
      options << :o if output
      return work options
    end
    
    def comment(testmode=false, output=true)
      options = [:s,:c]
      options << :t if testmode
      options << :o if output
      return work options
    end
    
    def replace(testmode=false, output=true)
      options = [:s,:c,:r]
      options << :t if testmode
      options << :o if output
      return work options
    end
    
    # Fügt code zum app_startup hinzu, falls der app_startup vorhanden ist)
    def add_app_startup_code(code=nil)
      @app_startup_code << code unless code.nil?
    end
    
  private
  
    def work(options = nil)
      result_all = Array.new
      @filesearcher.freeze
      @filesearcher.files.each do | file |
        begin
          code = Code.new(file, @parts)
          search = Search.new code.items
          search.pattern = @searchpattern unless @searchpattern.nil?
          search.testmode = options.include? :t
          result_one = search.search
          result_all.concat result_one
          # warn options
          output = "File #{File.basename(file)} has #{result_one.count} results. "
          if options.include?(:r) or options.include?(:c)
            if @destination.nil?
              output += "Saved. "
              if options.include? :t
                output = "Test: #{output}"
              else
                # file include
                if((result_one.count > 0 or @fileinclude_allways) and @fileinclude != nil)
                  library_item = code.add_library @fileinclude
                  item_write_comment(code, library_item, @fileinclude_comment) unless @fileinclude_comment.nil?
                end
                # app startup	
                app_startup_item = code.app_startup_item
                if(@app_startup_code.count > 0 and app_startup_item != nil)
                  output += "AppStartup changed. "
                  @app_startup_code.reverse.each do | startup_code |
                    new_item = app_startup_item.insert_new_child( startup_code )
                    new_comment_item = new_item.insert_new_child( @app_startup_code_comment )
                    new_comment_item.item_comment
                    code.items.insert(code.items.index(app_startup_item) + 1, new_item)
                    code.items.insert(code.items.index(new_item) + 1, new_comment_item)
                  end
                end
                code.save
              end
            else
              filename = "#{@destination}/#{File.basename(file)}"
              output += "Saved as #{filename}. "
              if options.include? :t
                output = "Test: #{output}"
              else
                code.save_as filename
              end
            end
          else
            output += "Searched. "
            output = "Test: #{output}" if options.include? :t
          end 
          if options.include? :o
            puts output 
            STDOUT.flush
          end
        rescue CodeException => ex
          if options.include? :t
            raise ex
          else
            warn "Analyze: #{ex.code.filename} - #{ex}"
          end
        end
      end
      return result_all
    end
    
    # Der Kommentar wird unter dem Item angelegt
    # parent = das parent item unter dem der Kommentar als Item eingefügt werden soll
    # info = der text der als Code-Teil im Item zu sehen ist 
    def item_write_comment(code, parent, info)
      comment_item = parent.copy
      comment_item.parent = parent
      comment_item.childs = []
      comment_item.code = "#{info}"
      comment_item.item_comment
      comment_item.level = parent.level + 1
      code.items.insert(code.items.index(parent) + 1, comment_item)
      parent.childs << comment_item
      parent.refresh_child_indicator
      comment_item.refresh_child_indicator
      comment_item
    end
    
  end
  
end