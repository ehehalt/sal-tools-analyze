# coding: utf-8

module Sal
  
  class FileSearcher
  
    # creates a new FileSearcher
    # as parameter, a filter with shelloptions could be set
    # for example: FileSearcher.new("*.rb")
    def initialize(filter = /.*/)
      @filter = filter
      @recursive = true
      @dirs = []
      @files = []
      @automatic = true
      @frozen = false
      @blacklistfilter
    end
  
    attr_accessor :filter, :recursive, :dirs, :files, :blacklistfilter
  
    # frozen could be set with the method freeze
    attr_reader   :frozen
  
    # gets the files found for the setted dirs and filters
    # the returned array is allways up-to-date
    # if the array should be frozen, use the method freeze
    def files
      fill_files unless frozen
      @files
    end
  
    # freeze the FileSearcher, so the files returned will
    # allways the same and don't would be updated if the
    # files method is called. freeze(false) will defrosting
    # the class ...
    def freeze(frozen=true)
      if @frozen != frozen and frozen
        fill_files if @files.empty?
      end  
      @frozen = frozen
    end
  
  private
  
    # clears the files property
    def clear_files
      @files = []
    end
  
    # refills the files property
	# fill_files changed to use regexp pattern because the pattern "*.app" with 
	# Dir.glob is not case sensitive and "*.ap[lpt]" is case sensitive. Then the
	# flag File::FNM_CASEFOLD has no function ... it seems this is a bug in Dir.glob.
	# Stand Ruby 1.9.2p290.
    def fill_files
      clear_files
      glob_pattern = (@recursive ? "**/*" : "*")
      search_pattern = @filter.nil? ? ".*" : @filter
      pwd = Dir.pwd
      if @dirs.count == 0
        @dirs << pwd
      end
      @dirs.each do | dir |
        Dir.chdir dir
        Dir.glob(glob_pattern, File::FNM_CASEFOLD) do | file |
          if file =~ search_pattern
            @files << File.realpath(file) unless File.directory? file
          end
        end
      end
      @files.uniq!
      @files.delete_if do |file|
        file.downcase =~ @blacklistfilter
      end
      Dir.chdir pwd
    end

  end

end