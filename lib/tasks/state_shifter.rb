namespace :state_shifter do
  desc 'Draws state machines using GraphViz (options: CLASS=User,Vehicle; FONT=Arial; FORMAT=png; ORIENTATION=portrait; OUTPUT_FILENAME=filename)'
  task :draw do

    unless ENV['CLASS']
      puts 'you need to specify at least one CLASS'
      exit 1
    end

    options = {}

    options[:format]          = ENV['FORMAT'] || 'png'
    options[:output_filename] = ENV['OUTPUT_FILENAME'] || "#{ENV['CLASS']}.#{options[:format]}"
    options[:font]            = ENV['FONT'] || 'Arial'
    options[:orientation]     = ENV['ORIENTATION'] || 'portrait'

    if defined?(Rails)
      Rake::Task['environment'].invoke
    else
      $:.unshift(File.dirname(__FILE__) + '/..')
      require 'state_shifter'
    end

    StateShifter::Draw.graph(ENV['CLASS'], options)
  end
end
