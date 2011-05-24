require 'test_helper'

class BcScrapperControllerTest < ActionController::TestCase
  test "should get pf_cheque_especial" do
    get :pf_cheque_especial
    assert_response :success
  end

end
