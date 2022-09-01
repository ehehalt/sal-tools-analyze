# coding: utf-8

require_relative "item.rb"

module Sal
    
  # Die Klasse representiert eine einzelnes File Include.
  class Function

    def initialize( item )
      @item = item
      item.code =~ /Function:\s(\S+)/
      @name = get_name(item.code)
    end

    attr_accessor :name, :item

  private

    def get_name(code)
      code =~ /Function:\s(\S+)/
      return $1
    end

  end

end

