# coding: utf-8

require_relative "item.rb"

module Sal
  
  class Class

    def initialize( item )
      @item = item
      item.code.chomp =~ /^(.*? Class): (.*)$/
      @type = $1
      @name = $2
      @functions = nil
    end

    attr_accessor :name, :item, :type

    # Functions analyzed lazy
    def functions
      if( @functions.nil? )            
        _analyze            
      end
      return @functions
    end

  private

    def _analyze
      @functions = []
      
      @item.childs.each do | item |
        if(item.level == 4 and item.code.start_with? "Functions")
          item.childs.each do | item |
            @functions << item if item.code.start_with? "Function"
          end
        end
      end
    end

  end
    
end

