# coding: utf-8

require_relative 'search'

module Sal
  
  # Klasse für ein Suchen/Ersetzen Pattern
  class SearchPattern
    
    def initialize(search, replace=nil, type=SearchType::COMPLETE, function=SearchFunction::REPLACE)
      # search has to be a regular expression
      self.search = search
      # replace is nil or a string value
      @replace = replace
      # comment is nil or a string value (comment in a subline in the text)
      @comment = nil
      # replace with code backup backups the code line in a commented subline
      @backup_code = true
      # search type sets the SearchPattern properties search_in_comments and search_in_code
      self.type = type
      # function is the function of the pattern (search, replace, delete)
      @function = function
    end
  
    attr_reader :search, :function
    attr_accessor :replace, :comment
    attr_accessor :search_in_comments, :search_in_code
    attr_accessor :backup_code
    
    def search=(value)
      unless value.nil?
        if value.class != Regexp
          raise "Sal::SearchPattern search has to be a Regexp!"
        end
      end
      @search = value
    end
          
    
    def type=(value)
      case value
      when SearchType::COMPLETE
        @search_in_comments = true
        @search_in_code = true
      when SearchType::CODE
        @search_in_code = true
        @search_in_comments = false
      when SearchType::COMMENTS
        @search_in_comments = true
        @search_in_code = false
      else
        raise "Sal::SearchPattern#type= SearchType '#{value}' unknown"
      end
    end 
    
    def type
      if @search_in_comments and @search_in_code
        return SearchType::COMPLETE
      elsif @search_in_comments
        return SearchType::COMMENTS
      elsif @search_in_code
        return SearchType::CODE
      else
        raise "Sal::SearchPattern#type No equivaluent Type found"
      end
    end
    
  end

end