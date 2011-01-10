require 'test_helper'

class RatesControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
 def "index" do
   get :index
   assert_response :success
 end
end
