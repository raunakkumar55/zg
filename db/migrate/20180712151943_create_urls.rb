class CreateUrls < ActiveRecord::Migration[5.2]
  def change
    create_table :urls, :options => 'COLLATE=utf8_general_ci' do |t|
      # No of URl character is not an issue here, max 2083 characters varchar(65535)
      # Initially value can be null
      t.string :long_url, :limit => 3000
      t.string :short_url, :limit => 20
      t.string :url_hash, :limit => 32
      t.timestamps
    end
  end
end
