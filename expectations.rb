require 'rspec/expectations'
require 'allocation_stats'
class << self; alias_method :inc,  :include; remove_method :include; end
inc RSpec::Matchers


stats = AllocationStats.trace do 
  "a string".should include("a")
  "a string".should include("str")
  "a string".should include("str", "g")
  "a string".should_not include("foo")
  [1, 2].should include(1)
  [1, 2].should include(1, 2)
  [1, 2].should_not include(17)
  
  {:a => 1, :b => 2}.should include(:a)
  {:a => 1, :b => 2}.should include(:a, :b)
  {:a => 1, :b => 2}.should include(:a => 1)
  {:a => 1, :b => 2}.should include(:b => 2, :a => 1)
  {:a => 1, :b => 2}.should_not include(:c)
  {:a => 1, :b => 2}.should_not include(:a => 2)
  {:a => 1, :b => 2}.should_not include(:c => 3)
end

puts stats.allocations(alias_paths: true).group_by(:sourcefile, :class).to_text