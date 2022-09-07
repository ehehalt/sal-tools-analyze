# coding: utf-8

require_relative "item.rb"

module Sal
  
  class PicTab

  	def initialize( item )
  		@item = item
      # .head 3 +  Picture: picTabs
  		item.code.chomp =~ /^(.*?): (.*)$/
  		@type = $1 # Picture
  		@name = $2 # picTabs
  	end

  	attr_accessor :name, :item, :type

  	def tab_names
      analyze_pic_tab if @tab_names.nil? 
      @tab_names
    end

    def tab_labels
      analyze_pic_tab if @tab_labels.nil? 
      @tab_labels      
    end

private

    def analyze_pic_tab
      nameprops = item.properties.select { | prop | prop.key == "TabNames"}
      labelprops = item.properties.select { | prop | prop.key == "TabLabels"}
      @tab_names = []
      @tab_labels = []
      if nameprops.count > 0 
        tn = nameprops.first
        if tn.type == :array
          @tab_names = @tab_names + tn.value
        else
          @tab_names << tn.value
        end
      end
      if labelprops.count > 0
        tl = labelprops.first
        if tl.type == :array
          @tab_labels = @tab_labels + tl.value
        else
          @tab_labels << tl.value
        end
      end
    end

  end

end