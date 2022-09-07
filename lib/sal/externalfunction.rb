# coding: utf-8

require_relative "item.rb"
require_relative "external.rb"

module Sal
 
  # External function in an external library (DLL)
  class ExternalFunction

    def initialize( external, item )
      @external = external
      @item = item
      @name = nil
      @ordinal = -1
      @parameters = Array.new
      
      #@appears = 0
      #@defs = Array.new
      #@calls = Hash.new # hash with files whith a child code line array
      
      _analyze
      @key = @external.name + "::" + @name
    end

    attr_accessor :external, :item , :name, :ordinal, :key, :parameters # :appears, :defs, :calls

  private

    def _analyze
      @name = $1 if @item.code =~ /Function: (.*)$/
      @item.childs.each do | child |
        # ordinal number
        @ordinal = $1.to_i if child.code =~ /Export Ordinal: (\d+)/
        
        # parameter
        if child.level == 5 and child.code =~ /Parameters/
          child.childs.each do | parameter |
            @parameters << parameter unless parameter.commented?
          end
        end
      end
    end
  
  end
      
end