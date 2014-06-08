class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string   :external_id
      t.string   :event_name
      t.text     :event_description
      t.datetime :event_start_date
      t.datetime :event_end_date
      t.string   :event_location
      t.string   :organizer_name
      t.string   :organizer_email
      t.string   :event_type
      t.string   :event_url
      t.string   :presenter
      t.timestamps
    end
  end
end