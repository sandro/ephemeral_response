class Time
  class << self
    alias now_without_travel now

    def travel(travel_string)
      @travel_string = travel_string
      yield
    ensure
      @travel_string = nil
    end

    def now
      if @travel_string
        Time.parse(@travel_string, now_without_travel)
      else
        now_without_travel
      end
    end
  end
end
