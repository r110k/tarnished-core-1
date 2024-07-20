require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "验证码" do
  post '/api/v1/validation_codes' do
    example "请求发送验证码" do
      do_request

      expect(status).to eq 422
    end
  end
end