class CreateUrls < ActiveRecord::Migration[5.2]
  def change
    create_table :urls do |t|
      # No of URl character is not an issue here, max 2083 characters varchar(65535)
      t.string :long_url, :limit => 3000, :null => false
      t.string :short_url, :limit => 20, :null => false
      t.string :url_hash, :limit => 32, :null => false
      t.timestamps
    end
  end
end
