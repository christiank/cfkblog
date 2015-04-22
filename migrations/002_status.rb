require 'sequel'

Sequel.migration do
  change do
    alter_table(:posts) do
      add_column :published, TrueClass, :default => false
    end
  end
end
