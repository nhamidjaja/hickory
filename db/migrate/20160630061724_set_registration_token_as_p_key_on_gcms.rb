class SetRegistrationTokenAsPKeyOnGcms < ActiveRecord::Migration
  def up
    execute "ALTER TABLE gcms ADD PRIMARY KEY (registration_token);"
  end

  def down
    execute "ALTER TABLE gcms DROP CONSTRAINT gcms_pkey;"
  end
end
