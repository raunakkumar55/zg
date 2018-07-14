require 'test_helper'

class UrlTest < ActiveSupport::TestCase


  # Sample unit test case: Just picking one test case as assignment task

  test "all domain variations result to same shorten url" do
    variations = ["go.com", "www.go.com", "http://go.com"]
    result_token = nil
    variations.each do |long_url|
      short_token = Url.get_short_url(long_url)
      result_token = short_token if result_token.nil?
      assert(short_token == result_token)
    end
  end


end
