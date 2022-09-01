# coding: utf-8

require_relative "item.rb"

module Sal
    
  # Die Klasse representiert eine einzelnes File Include.
  class Library

    def initialize( item )
      @item = item
      item.code =~ /(Dynalib|File Include):\s(\S+)/
      @name = get_name(item.code)
      @type = get_type(item.code)
    end

    attr_accessor :item
    attr_reader :name, :type

  private

    def get_name(code)
      code =~ /(Dynalib|File Include):\s(\S+)/
      return $2
    end

    def get_type(code)
      if code =~ /Dynalib/
        return :Dynalib
      elsif code =~ /File Include/
        return :FileInclude
      else
        return :Unknown
      end
    end

  end

end