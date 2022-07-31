module ControllerMacros
  include Warden::Test::Helpers

  def sign_in_user(user)
    @user = user
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in @user
  end

  def current_user
    @user
  end
end
