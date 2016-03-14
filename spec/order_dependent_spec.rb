RSpec.configure do |config|
  config.order = :random
end

class Global
  @@counter = 0
  def self.counter; @@counter; end
  def self.increment_counter; @@counter += 1; end
end

RSpec.describe Global do
  it "#counter is initialized to zero" do
    expect(described_class.counter).to eq 0
  end

  it "#increment_counter adds one to #counter" do
    described_class.increment_counter
    expect(described_class.counter).to eq 1
  end
end