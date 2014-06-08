class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  def index
    @events = Event.page(params[:page]).per(30)
  end

  def future_events
    w = EventListingWorker.new.perform("http://www.baychi.org/calendar")
    redirect_to events_path, notice: "Events added"
  end

  def past_events
    w = EventListingWorker.new.perform("http://www.baychi.org/calendar/past")
    redirect_to events_path, notice: "Events added"
  end

  def show
  end

  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end
end