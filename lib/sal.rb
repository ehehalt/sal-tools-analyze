#!/opt/local/bin/ruby

module Sal
  VERSION = "1.1.4"

  autoload :Analyse "sal/analyse"
  autoload :Cdk, "sal/cdk"
  autoload :Class, "sal/class"
  autoload :Code, "sal/code"
  autoload :CodeHelper, "sal/codehelper"
  autoload :CodeSearcher, "sal/codesearcher"
  autoload :Command, "sal/command"
  autoload :Constant, "sal/constant"
  autoload :ErrorLog, "sal/errorlog"
  autoload :External, "sal/external"
  autoload :ExternalFunction, "sal/externalfunction"
  autoload :FileSearcher, "sal/filesearcher"
  autoload :Format, "sal/format"
  autoload :Function, "sal/function"
  autoload :Item, "sal/item"
  autoload :Library, "sal/library"
  autoload :Parser, "sal/parser"
  autoload :Search, "sal/search"
  autoload :SearchPattern, "sal/searchpattern"
  autoload :StringProperties, "sal/stringproperties"
  autoload :Version, "sal/version"
end
