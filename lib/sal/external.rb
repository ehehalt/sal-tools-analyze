# coding: utf-8

require_relative "item.rb"

module Sal
  
  # This class represent an external library (DLL)
  class External

    def initialize( item )
      @item = item
      @name = item.code.gsub(/Library name: /,"")
      @functions = nil
    end

    attr_accessor :name, :item

    # Functions analyzed lazy
    def functions
      if( @functions.nil? )            
        _analyze            
      end
      return @functions
    end

  private

    def _analyze
      @functions = Array.new
      @item.childs.each do | item |
        if item.code =~ /Function: /
          @functions << ExternalFunction.new( self, item )
        end
      end
    end

  end
    
end