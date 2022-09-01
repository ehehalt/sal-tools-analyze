Gem::Specification.new do | s |
    s.name          = "sal"
    s.summary       = "Analyse SAL-Code"
    s.description   = File.read(File.join(File.dirname(__FILE__), 'readme'))
    s.requirements  = [ 'An installed dictionary (most Unix systems have one)']
    s.version       = '1.1.9'
    s.author        = "Michael Ehehalt"
    s.email         = "mike42@hotmail.de"
    s.homepage      = "http://localhost:8808"
    s.platform      = Gem::Platform::RUBY
    s.required_ruby_version     = '>=1.9'
    s.files         = Dir['bin/**', 'lib/**/**', 'test/**/**']
    s.executables   = ["salinfo", "salsearch", "salconvert", "salanalyse", "salbinary", "salpictabinfo", "saldepend"]
    s.test_files    = Dir["test/tes*.rb"]
    s.licenses      = ['MIT']
end
