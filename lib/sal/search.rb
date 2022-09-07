# coding: utf-8

require_relative 'searchpattern.rb'

module Sal
  
  # SearchResultException ...
  class SearchResultException < RuntimeError
    attr :filename
    def initialize(filename)
      @filename = filename
    end
  end
  
  # Result of a search
  class SearchResult
    
    def initialize(src, dst, replaced = nil, testmode = false)
      @src = src
      @dst = dst 
      @replaced = replaced
      @testmode = testmode
      if @replaced.nil?
        @replaced = (@replaced.nil? ? (@src != @dst) : @replaced)
        if @src.class == String and @dst.class == String
          @replaced = false if @scr.eql? @dst
        end
      end
    end
    
    attr_reader :src, :dst, :replaced, :testmode
    
    # Alias for replaced
    def changed
      @replaced
    end
    
    # Alias for replaced
    def changed?
      @replaced
    end
    
    # Alias for replaced
    def replaced?
      @replaced
    end
    
    # Alias for src
    def source
      @src
    end
    
    # Alias for dst
    def destination
      @dst
    end
    
    # Alias for testmode
    def testmode?
      @testmode
    end
    
    def to_s
      "  Source: #{@src}\n  Destination: #{@dst}"
    end
    
  end
  
  # Enumeration for the different search types
  module SearchType
    
    # Search in the complete source code
    COMPLETE = :complete
    # Search only in uncommented code
    CODE = :code
    # Search only in comments, but not in code lines
    # that are only commented through the commented parents
    COMMENTS = :comments
  
  end
  
  # Enumeration fot the different search functions
  module SearchFunction
    
    # Search
    SEARCH = :search
    
    # Replace (Default)
    REPLACE = :replace
    
    # Remove (inclusive childs)
    REMOVE = :remove
    
  end
  
  # Search and replace class
  # The original lines could be inserted as comment as child from the
  # changed line, or normal comments could be inserted.
  class Search
    
    def initialize(items = nil)
      @items = items
      @pattern = []
      @backup_code = false;
      @backup_info = nil
      @search_in_code = false
      @testmode = false
    end
    
    attr_accessor :search_in_code
    attr_accessor :backup_code,:backup_info, :testmode, :pattern

    # Set remove pattern (calls internally add_pattern)
    def add_remove_pattern(search = nil, type = SearchType::COMPLETE)
      add_pattern( SearchPattern.new( search, nil, type, SearchFunction::REMOVE ) )
    end
        
    # Set replace pattern (calls internally add_pattern)
    def add_replace_pattern(search = nil, replace = nil, type = SearchType::COMPLETE)
      add_pattern( SearchPattern.new( search, replace, type ) )
    end
    
    # Set search pattern (calls internally add_pattern)
    def add_search_pattern(search = nil, type = SearchType::COMPLETE)
      add_pattern( SearchPattern.new( search, nil, type ) )
    end
    
    # Set pattern
    def add_pattern( pattern )
      @pattern << pattern
      return pattern
    end
    
    # new search for codesearcher
    def search(testmode = nil)
      @testmode = testmode unless testmode.nil?
      results = []
      # => items have to clone first to prevent endless loop while _backup itm!
      @items.clone.each do | item | 
        fnd = false
        # => copy item first for results as original value
        src = item.copy 
        wrk = @testmode ? item.copy : item
        @pattern.each do | pattern |
          if item_in_search_type?(wrk, pattern.type)
            if wrk.code =~ pattern.search
              fnd = true
              if @testmode
                # nothing to do ...
              else
                item_do_pattern(wrk, pattern)
              end
            end
          end
        end
        dst = wrk.copy
        results << SearchResult.new(src, dst, nil, @testmode) if fnd
      end
      return results
    end
    
    # Return the found items.
    # If @search_in_comments is set the comments would returned additionaly
    def get_items(search_type=SearchType::COMPLETE)
      result = []
      @items.each do | item |
        result << item if item_in_search_type? item, search_type
      end
      result
    end
    
    # Check if the item is in the SearchType
    def item_in_search_type?(item, type=SearchType::COMPLETE)
      result = case type
      when SearchType::CODE
        item.is_code_line? and (not item.commented?)
      when SearchType::COMMENTS
        not item.is_code_line?
      else
        true
      end
      result
    end
    
    def item_do_pattern(item, pattern)
      
      if pattern.function == Sal::SearchFunction::REMOVE
        
        # Removes the item from the sourcecode
        source_code = item.source_code
        source_code.remove_item item # unless source_code.nil?
        
      elsif pattern.function == Sal::SearchFunction::REPLACE
        
        # Comment the found item
        comment_item = item_write_comment(item, pattern.comment) unless pattern.comment.nil?
        parent_for_backup = ( comment_item.nil? ? item : comment_item )
      
        # Backup the found item if this should be done and if there is a replace string
        unless pattern.replace.nil?
          backup_item = item_backup(item, parent_for_backup) if pattern.backup_code
          item.code.gsub!(Regexp.new(pattern.search), pattern.replace)
        end

      else

        # Search => nothing to do
        
      end
      
    end
      
    # The comment would be inserted as child of the item
    # parent = the parent item 
    # info = the text - seen as code part of the item
    def item_write_comment(parent, info)
      comment_item = parent.copy
      comment_item.parent = parent
      comment_item.childs = []
      comment_item.code = "#{info}"
      comment_item.item_comment
      comment_item.level = parent.level + 1
      @items.insert(@items.index(parent) + 1, comment_item)
      parent.childs << comment_item
      parent.refresh_child_indicator
      comment_item.refresh_child_indicator
      comment_item
    end
    
    # The original item as child comment under the new item
    def item_backup(item, parent)
      backup_item = item.copy
      backup_item.parent = parent
      backup_item.childs = []
      backup_item.item_comment
      backup_item.level = parent.level + 1
      @items.insert(@items.index(parent) + 1,backup_item)
      parent.childs << backup_item
      parent.refresh_child_indicator
      backup_item.refresh_child_indicator
      backup_item
    end
    
  private
    
    # Deprecated -> search
    # Takes a backup of the item
    def _backup(item)
      pos = @items.index(item) + 1
      info = _backup_info(item, item, backup_info) unless backup_info.nil?
      bckp = _backup_item(item, info) if backup_code
    end
    
    # Deprecated --> _backup
    # The comment would be copied as child unter the item
    # item = the item as base of the comment
    # parent = the parent item for the comment
    # info = the text for the code part of the comment
    def _backup_info(item, parent, info)
      new_item = item.copy
      new_item.parent = parent
      new_item.childs = []
      new_item.code = "#{info}"
      new_item.item_comment
      new_item.level = parent.level + 1
      @items.insert(@items.index(parent) + 1,new_item)
      parent.childs << new_item
      parent.refresh_child_indicator
      new_item.refresh_child_indicator
      new_item
    end
    
    # Deprecated --> _backup
    # The original code would be added as child under the changed item
    def _backup_item(item, parent)
      new_item = item.copy
      new_item.parent = parent
      new_item.childs = []
      new_item.item_comment
      new_item.level = parent.level + 1
      @items.insert(@items.index(parent) + 1,new_item)
      parent.childs << new_item
      parent.refresh_child_indicator
      new_item.refresh_child_indicator
      new_item
    end
    
  end

end
