class AddTsvectorColumnsToFeeders < ActiveRecord::Migration
  # rubocop:disable Metrics/MethodLength
  def up
    add_column :feeders, :tsv, :tsvector
    add_index :feeders, :tsv, using: 'gist'

    execute <<-SQL
      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON feeders FOR EACH ROW EXECUTE PROCEDURE
      tsvector_update_trigger(
        tsv, 'pg_catalog.simple', title
      );
    SQL

    now = Time.current.to_s(:db)
    update("UPDATE feeders SET updated_at = '#{now}'")
  end

  def down
    execute <<-SQL
      DROP TRIGGER tsvectorupdate
      ON feeders
    SQL

    remove_index :feeders, :tsv
    remove_column :feeders, :tsv
  end
end
