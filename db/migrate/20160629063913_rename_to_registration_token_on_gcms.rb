class RenameToRegistrationTokenOnGcms < ActiveRecord::Migration
  def change
    rename_column :gcms, :registration_id, :registration_token
  end
end
