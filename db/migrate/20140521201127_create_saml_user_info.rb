class CreateSamlUserInfo < ActiveRecord::Migration
  def change
    create_table :saml_user_infos do |t|
      t.integer :user_id, null: false
      t.integer :saml_user_id, null: false
      t.string :email, null: false
      t.timestamps
    end

    add_index :saml_user_infos, [:saml_user_id], unique: true
    add_index :saml_user_infos, [:user_id], unique: true
  end
end
