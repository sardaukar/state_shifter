require 'rails'

module StateShifter
  class Railtie < ::Rails::Railtie

    rake_tasks do
      require_relative '../tasks/state_shifter.rake'
    end

  end
end
