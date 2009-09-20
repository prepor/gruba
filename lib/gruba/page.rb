module Gruba
  class Page
    attr_accessor :options, :doc
    def initialize(options = {})
      self.options = options
    end

    def set_url
      Gruba.current_session.set_url(url)
    end

    def receive
      self.doc = Gruba.current_session.agent.get(url)
    end

    def perform      
      if options[:url]
        Gruba.logger.info "Parsing page #{options[:url]}"
        Gruba.with_rescues do
          receive
          Gruba::Element.new(self.doc, options[:parent], &options[:proc]) if options[:proc]
        end
        Gruba.current_session.perfomed_page options[:url] 
      end
    end

    def url
      options[:url]
    end

  end
end
