# coding: utf-8

require_relative "item.rb"

module Sal
  
  # Die Klasse repräsentiert eine Konstante
  class Constant
    
    # Initialisierung über das zugehörige Item
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
    
    # Item Funktionalität anzapfen um einfachere Aufrufe in der Anwendung der Klasse zu ermöglichen
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

