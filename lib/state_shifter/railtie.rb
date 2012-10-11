require 'rails'

module StateShifter
  class Railtie < ::Rails::Railtie

    rake_tasks do
      require 'lib/tasks/state_shifter.rake'
    end

  end
end
