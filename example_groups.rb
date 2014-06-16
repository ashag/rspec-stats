require 'rspec/core'
require 'allocation_stats'


stats = AllocationStats.trace do 
  1000.times do |t|
    RSpec.describe "#{t} example groups" do
      it "has one example"
    end
  end
end

puts stats.allocations(alias_paths: true).group_by(:sourcefile, :class).to_text


