class RemoveIndexUsersOnResetPasswordToken < ActiveRecord::Migration[6.0]
  def up
    remove_index :users, name: :index_users_on_reset_password_token
  end
end
