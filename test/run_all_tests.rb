f = File.expand_path(File.join(File.dirname(__FILE__),'functional','*.rb'))
Dir.glob(f).each { |test| require test }

f = File.expand_path(File.join(File.dirname(__FILE__),'misc_tests','*.rb'))
Dir.glob(f).each { |test| require test }
