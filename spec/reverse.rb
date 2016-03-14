RSpec.configure do |c|
  c.register_ordering(:global, &:reverse)
end
