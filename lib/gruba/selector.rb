module Gruba
  class Selector
    attr_accessor :options
    def initialize(options = {})
      self.options = options
    end

    def perform
      #puts options[:selector]
      options[:doc].search(options[:selector]).map do |el|
        Gruba::Element.new(el, options[:parent], &options[:proc])
      end
    end

  end
end
