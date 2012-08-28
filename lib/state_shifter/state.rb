module StateShifter

  class State
  
    attr_reader :name, :events
    attr_accessor :entry_callback, :entry_callback_args

    def initialize name
      @name = name
      @events = {}
      @entry_callback = nil
      @entry_callback_args = []
    end

    def has_entry_callback?
      !@entry_callback.nil?
    end

  end

end
