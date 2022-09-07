# coding: utf-8

require_relative "item.rb"
require_relative "pictab.rb"

module Sal
  
  # Represents a Form Window, Table Window or a Dialog Box
  class Window

  	def initialize( item )
  		@item = item
  		item.code.chomp =~ /^(.*?): (.*)$/
  		@type = $1
  		@name = $2
  	end

  	attr_accessor :name, :item, :type, :pictab, :contents

  	# TODO: Class, Functions, Messages, ...

    def pictab
      analyze_pictab if @pictab.nil?
      @pictab
    end

    def contents
      analyze_contents if @contents.nil?
      @contents
    end


private

    def analyze_pictab
      pt = item.childs_flat.select { | item | item.pictab? }.first
      @pictab = Sal::PicTab.new( pt ) unless pt.nil?
    end

    def analyze_contents
      ct = item.childs.select { | item | item.code == "Contents" }.first
      @contents = ct.childs.nil? ? [] : ct.childs
    end

  end

end