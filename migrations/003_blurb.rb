require 'sequel'

Sequel.migration do
  change do
    alter_table(:posts) do
      add_column :blurb, String, :text => true, :null => false, :default => ""
    end
  end
end
