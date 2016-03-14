RSpec.describe "intermittent failure" do
	let(:percentage) { rand * 100 }

  it "sixty percent of the time, it works every time" do
    expect(percentage).to be <= 60
  end
end