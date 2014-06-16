require 'rspec/core'
require 'allocation_stats'

stats = AllocationStats.trace do 
  describe "one example group" do
    1000.times do
      it "has a thousand examples"
    end
  end
end

puts stats.allocations(alias_paths: true).group_by(:sourcefile, :class).to_text

