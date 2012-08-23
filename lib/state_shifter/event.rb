module StateShifter
  class Event
    attr_reader :name, :from, :to, :guards, :callback

    def initialize from, name, to=nil, guards=nil, callback=nil
      @name = name
      @from = from
      @to = to
      @guards = [guards].flatten.compact
      @callback = callback
    end

    def has_guards?
      !@guards.nil?
    end

    def has_callback?
      !@callback.nil?
    end

  end
end
