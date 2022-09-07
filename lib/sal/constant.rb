# coding: utf-8

require_relative "item.rb"

module Sal
  
  class Constant
    
    # Initialisation with his item
    def initialize( item )
      @item = item
      @name = nil
      @value = nil
    end
    
    attr_accessor :item
    
    def name
      _analyze if(@name.nil?)
      return @name
    end
    
    def value
      _analyze if(@value.nil?)
      return @value
    end
    
    # Ist es eine System-Konstante?
    def system?
      ( @item.parent.code =~ /^System/ ) == nil ? false : true
    end
    
    # Ist es eine User-Konstante?
    def user?
      ( @item.parent.code =~ /^User/ ) == nil ? false : true
    end
    
    # Use Item functionality to get simpler calls in the usage of the class
    def method_missing(method, *args)
      if(@item.methods.include? method)
        return @item.send(method, *args )
      else
        super
      end
    end
  
  private
  
    def _analyze
      code =~ /^(\w+)\s*=\s*(\S.*?)$/
      @name = $1
      @value = $2
    end
  
  end
    
end

