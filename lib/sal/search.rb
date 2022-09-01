# coding: utf-8

require_relative 'searchpattern.rb'

module Sal
  
  # SearchResultException für den Fall ...
  class SearchResultException < RuntimeError
    attr :filename
    def initialize(filename)
      @filename = filename
    end
  end
  
  # Klasse für die Rückgabe eines Suchresults
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
    
    # Alias fuer replaced
    def changed
      @replaced
    end
    
    # Alias fuer replaced
    def changed?
      @replaced
    end
    
    # Alias fuer replaced
    def replaced?
      @replaced
    end
    
    # Alias fuer src
    def source
      @src
    end
    
    # Alias fuer dst
    def destination
      @dst
    end
    
    # Alias fuer testmode
    def testmode?
      @testmode
    end
    
    def to_s
      "  Source: #{@src}\n  Destination: #{@dst}"
    end
    
  end
  
  # Enumeration für die verschiedenen Suchtypen
  module SearchType
    
    # Search in the complete source code
    COMPLETE = :complete
    # Search only in uncommented code
    CODE = :code
    # Search only in comments, but not in code lines
    # that are only commented through the commented parents
    COMMENTS = :comments
  
  end
  
  # Enumeration für die verschiedenen Suchfunktionen
  module SearchFunction
    
    # Nach etwas suchen
    SEARCH = :search
    
    # Suchen und ersetzen (Default)
    REPLACE = :replace
    
    # Löschen (inklusive Childs)
    REMOVE = :remove
    
  end
  
  # Suchen und Ersetzen Klasse
  # Beim Ersetzen können einerseits die Zeilen in denen ersetzt wird
  # als Kommentarzeilen untergefügt werden und zweitens ein Kommentar
  # gesetzt werden (z.B. Datenbankmigration am ...)
  class Search
    
    # Initialisierung der Suchen und Ersetzen Instanz
    # Uebergabe der Items, die search and replace Arrays
    # werden leer angelegt und die Defaultwerte gesetzt.
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

    # Remove Pattern setzen (ruft intern add_pattern auf)
    def add_remove_pattern(search = nil, type = SearchType::COMPLETE)
      add_pattern( SearchPattern.new( search, nil, type, SearchFunction::REMOVE ) )
    end
        
    # Replace Pattern setzen (ruft intern add_pattern auf)
    def add_replace_pattern(search = nil, replace = nil, type = SearchType::COMPLETE)
      add_pattern( SearchPattern.new( search, replace, type ) )
    end
    
    # Search Pattern setzen (ruft intern add_pattern auf)
    def add_search_pattern(search = nil, type = SearchType::COMPLETE)
      add_pattern( SearchPattern.new( search, nil, type ) )
    end
    
    # Pattern setzen
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
    
    # Gibt die Items zurueck. 
    # Je nachdem wir das Property @search_in_comments
    # gesetzt ist werden alle Items oder nur die nicht 
    # kommentierten zurueckgegeben.
    def get_items(search_type=SearchType::COMPLETE)
      result = []
      @items.each do | item |
        result << item if item_in_search_type? item, search_type
      end
      result
    end
    
    # Prüft, ob das Item im SearchType enthalten ist
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
      
    # Der Kommentar wird unter dem Item angelegt
    # parent = das parent item unter dem der Kommentar als Item eingefügt werden soll
    # info = der text der als Code-Teil im Item zu sehen ist 
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
    
    # Das Originalitem wird als Kommentar unter den Parent kopiert
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
    # Erstellt ein Backup von einem Item 
    # Besteht aus zwei Teilen: Backup des Items und Kommentar setzen (je nach Einstellung)
    def _backup(item)
      pos = @items.index(item) + 1
      info = _backup_info(item, item, backup_info) unless backup_info.nil?
      bckp = _backup_item(item, info) if backup_code
    end
    
    # Deprecated --> _backup
    # Der Kommentar wird unter das Item kopiert
    # item = das Item für den ein Kommentar gebaut werden soll
    # parent = das parent item unter dem der Kommentar als Item eingefügt werden soll
    # info = der text der als Code-Teil im Item zu sehen ist 
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
    # Der Originalcode wird als Kommentar unter das veränderte Item kopiert
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
