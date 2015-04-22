require 'sequel'

Sequel.migration do
  change do
    create_table(:posts) do
      primary_key :id
      String :title, :text => true, :null => false
      DateTime :timestamp, :null => false
      String :body, :text => true, :null => false
      String :slug, :text => true, :null => false
      String :tags, :text => true, :null => false # Actually a JSON array
    end
  end
end
