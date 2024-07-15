require 'rails_helper'

RSpec.describe User, type: :model do
  it '📬 有 email' do
    user = User.new email: 'xusong@hangzhou.com'
    expect(user.email).to  eq('xusong@hangzhou.com')
  end
end
