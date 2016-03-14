RSpec.describe "never failing" do
  it "true is" do
    expect(true).to be
  end

  it "false isn't" do # This will always fail
    expect(false).to be
  end
end