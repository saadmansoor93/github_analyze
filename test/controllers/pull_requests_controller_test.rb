require 'test_helper'

class PullRequestsControllerTest < ActionDispatch::IntegrationTest
  test "should get ramda" do
    get pull_requests_ramda_url
    assert_response :success
  end

end
