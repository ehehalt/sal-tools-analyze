# coding: utf-8

module Sal
  
  # Ermittelt, ob eine Quellcodezeile Quellcode ist oder Strukturcode
  module Command

    @@commands = { 
      :break => "Break", 
      :call => "Call",
      :case => "Case",                # => Select Case
      :default => "Default",          # => Select Case
      :else => "Else",
      :else_if => "Else If",
      :if => "If",
      :loop => "Loop",
      :on => "On",
      :return => "Return",
      :select_case => "Select Case",
      :set => "Set",
      :when => "When",
      :while => "While"  
    }

     @@non_commands = {
      :outline_version =>  "Outline Version",
      :design_time_settings =>  "Design-time Settings",
      :default_classes =>  "Default Classes",
      :class =>  "Class:",
      :property_template =>  "Property Template",
      :window_defaults =>  "Window Defaults",
      :formats =>  "Formats",
      :class_dll_name =>  "Class DLL Name",
      :title =>  "Title",
      :icon_file =>  "Icon File",
      :accessories_enabled =>  "Accessories Enabled?",
      :display_settings =>  "Display Settings",
      :visible =>  "Visible?",
      :application_description =>  "Application Description:",
      :desicrption =>  "Description:"
    }
    
    # Ermittelt anhand der Quellcodezeile ob es sich 
    # um Quellcode (Set bOk = true) handelt oder um 
    # Strukturcode (Windows Parameters)
    def Command.is_code_line?(line)
      @@commands.each_value do | command |
        return true if line.start_with? "#{command} "
      end
      return false
    end
  
  end

end
