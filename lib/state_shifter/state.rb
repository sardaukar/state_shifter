module StateShifter

  class State
  
    attr_reader :name, :events
    attr_accessor :entry_callback

    def initialize name
      @name = name
      @events = {}
      @entry_callback = nil
    end

    def has_entry_callback?
      !@entry_callback.nil?
    end

  end

end
