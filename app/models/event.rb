class Event < ActiveRecord::Base
  ## Validations ##
  validates :event_name, presence: true
  validates :event_name, uniqueness: {scope: [:event_start_date, :event_end_date]}
end