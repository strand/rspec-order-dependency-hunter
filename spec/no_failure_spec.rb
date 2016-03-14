RSpec.describe "never failing" do
  it "true is" do
    expect(true).to be
  end

  it "false isn't" do
    expect(false).not_to be
  end
end