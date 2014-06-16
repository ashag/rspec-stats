require 'rspec/core'
require 'allocation_stats'
include RSpec::Mocks


stats = AllocationStats.trace do
   # allowing messages
  RSpec.describe "double" do
    it "raises errors when messages not allowed or expected are received" do
      dbl = double("Some Collaborator", :foo => 3, :bar => 4)
      expect(dbl.foo).to eq(3)
      expect(dbl.bar).to eq(4)
    end
  end

  # expecting messages
  RSpec.describe "A fulfilled positive message expectation" do
    it "passes" do
      dbl = double("Some Collaborator")
      expect(dbl).to receive(:foo)
      dbl.foo
    end
  end

  RSpec.describe "A negative message expectation" do
    it "fails when the message is received" do
      dbl = double("Some Collaborator").as_null_object
      expect(dbl).not_to receive(:foo)
      dbl.foo
    end
  end

  RSpec.describe "A negative message expectation" do
    it "passes if the message is never received" do
      dbl = double("Some Collaborator").as_null_object
      expect(dbl).not_to receive(:foo)
    end
  end

  # partial test doubles
  class User
    def self.find(id)
      :original_return_value
    end
  end

  RSpec.describe "A partial double" do
    it "redefines a method" do
      allow(User).to receive(:find).and_return(:redefined)
      expect(User.find(3)).to eq(:redefined)
    end

    it "restores the redefined method after the example completes" do
      expect(User.find(3)).to eq(:original_return_value)
    end
  end

  # null object doubles
  RSpec.describe "as_null_object" do
    it "returns itself" do
      dbl = double("Some Collaborator").as_null_object
      expect(dbl.foo.bar.bazz).to be(dbl)
    end
  end

  RSpec.describe "as_null_object" do
    it "can allow individual methods" do
      dbl = double("Some Collaborator", :foo => 3).as_null_object
      allow(dbl).to receive(:bar).and_return(4)

      expect(dbl.foo).to eq(3)
      expect(dbl.bar).to eq(4)
    end
  end

  # spies
  RSpec.describe "have_received" do
    it "passes when the message has been received" do
      invitation = double('invitation').as_null_object
      invitation.deliver
      expect(invitation).to have_received(:deliver)
    end
  end

  class Invitation
    def self.deliver; end
  end

  RSpec.describe "have_received" do
    it "passes when the expectation is met" do
      allow(Invitation).to receive(:deliver)
      Invitation.deliver
      expect(Invitation).to have_received(:deliver)
    end
  end

  RSpec.describe "An invitiation" do
    let(:invitation) { double("invitation").as_null_object }

    before do
      invitation.deliver("foo@example.com")
      invitation.deliver("bar@example.com")
    end

    it "passes when a count constraint is satisfied" do
      expect(invitation).to have_received(:deliver).twice
    end

    it "passes when an order constraint is satisifed" do
      expect(invitation).to have_received(:deliver).with("foo@example.com").ordered
      expect(invitation).to have_received(:deliver).with("bar@example.com").ordered
    end

    it "fails when a count constraint is not satisfied" do
      expect(invitation).to have_received(:deliver).at_least(3).times
    end

    it "fails when an order constraint is not satisifed" do
      expect(invitation).to have_received(:deliver).with("bar@example.com").ordered
      expect(invitation).to have_received(:deliver).with("foo@example.com").ordered
    end
  end

  # scope
  class Account
    class << self
      attr_accessor :logger
    end

    def initialize
      @balance = 0
    end

    attr_reader :balance

    def credit(amount)
      @balance += amount
      self.class.logger.log("Credited $#{amount}")
    end
  end

  RSpec.describe Account do
    it "logs each credit" do
      Account.logger = logger = double("Logger")
      expect(logger).to receive(:log).with("Credited $15")
      account = Account.new
      account.credit(15)
    end

    it "keeps track of the balance" do
      account = Account.new
      expect { account.credit(10) }.to change { account.balance }.by(10)
    end
  end
end

puts stats.allocations(alias_paths: true).group_by(:sourcefile, :class).to_text