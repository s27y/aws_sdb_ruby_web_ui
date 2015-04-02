require 'test_helper'

class AttributeControllerTest < ActionController::TestCase
  test "should get get" do
    get :get
    assert_response :success
  end

  test "should get put" do
    get :put
    assert_response :success
  end

  test "should get delete" do
    get :delete
    assert_response :success
  end

  test "should get select" do
    get :select
    assert_response :success
  end

  test "should get list" do
    get :list
    assert_response :success
  end

end
