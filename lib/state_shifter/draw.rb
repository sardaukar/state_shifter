module StateShifter

$:.unshift(File.dirname(__FILE__) + '/../..')
require 'examples/simple'
require 'pry'

  class Draw

    gem 'ruby-graphviz', '>=0.9.0'
    require 'graphviz'

    def self.graph klasses, options
      klasses.split(',').each do |klass|
        this_class = eval(klass)

        graph = GraphViz.new(:G, :rankdir => options[:orientation] == 'landscape' ? 'LR' : 'TB')

        this_class.state_machine_definition.states.each do |state_name, state_definition|
          node = state_definition.draw(graph, options)
          node.fontname = options[:font] if options[:font]
        end

        this_class.state_machine_definition.events.each do |event_name, event_definition|
          edge = event_definition.draw(graph, options)
          edge.fontname = options[:font] if options[:font]
        end

        graphvizVersion = Constants::RGV_VERSION.split('.')

        if graphvizVersion[0] == '0' && graphvizVersion[1] == '9' && graphvizVersion[2] == '0'
          outputOptions = {:output => options[:format], :file => options[:output_filename]}
        else
          outputOptions = {options[:format] => options[:output_filename]}
        end

        graph.output(outputOptions)
      end
    end
  end

end

