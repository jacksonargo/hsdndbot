require 'test_helper'

class AdvtypesControllerTest < ActionController::TestCase
  setup do
    @advtype = advtypes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:advtypes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create advtype" do
    assert_difference('Advtype.count') do
      post :create, advtype: {  }
    end

    assert_redirected_to advtype_path(assigns(:advtype))
  end

  test "should show advtype" do
    get :show, id: @advtype
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @advtype
    assert_response :success
  end

  test "should update advtype" do
    patch :update, id: @advtype, advtype: {  }
    assert_redirected_to advtype_path(assigns(:advtype))
  end

  test "should destroy advtype" do
    assert_difference('Advtype.count', -1) do
      delete :destroy, id: @advtype
    end

    assert_redirected_to advtypes_path
  end
end
