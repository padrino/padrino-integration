# rake test
require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.pattern = 'integration/**/test_*.rb'
  test.verbose = true
end