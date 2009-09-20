module Gruba
  class Session
    attr_accessor :data, :queue, :selectors, :current_host, :interval, :perfomed_pages, :queue_hash, :encoding, :data_elements_counter
    attr_accessor :logger
    def initialize
      self.data, self.selectors, self.queue, self.perfomed_pages, self.queue_hash = {}, {}, [], {}, {}
      self.interval = 0
      self.data_elements_counter = 0
      self.encoding = 'utf8'
    end

    def session_file
      Pathname.new('session.tmp')
    end

    def perform
      agent.history.max_size = 1

      while (page = queue.pop)
        #Thread.new do
          page.perform
        #end
        sleep interval if interval > 0
      end

      after_finish
    end

    def after_finish
      @finished = true
      on_finish.call if on_finish
    end

    def restore_session
      session_file.read.split("\n").each do |url|
        self.perfomed_pages[url] = true
      end
    end

    def write_session
      session_file.open('w') do |f|
        f.puts perfomed_pages.keys.join("\n")
      end
    end

    def perfomed_page(url)
      self.perfomed_pages[url] = true
    end

    def on_finish(&block)
      if block
        @on_finish = block
      else
        @on_finish
      end
    end

    def finished?
      !!@finished
    end

    def <<(page)
      self.queue << page
      self.queue_hash[page.url] = true
    end

    def data_element(name, params, page)
      if name =~ /(.+)!$/
        new_data_element($1, params, page)
      else
        update_data_element(name, params, page)
      end
    end

    def new_data_element(name, params)
      Gruba.logger.info "New data element '#{name}'"
      self.data_elements_counter += 1
      data[name] ||= []
      data[name] << params
    end

    def update_data_element(name, params, page)
      data[name].last.merge! params
    end

    def selector(options)
      if options[:name] && !options[:block] && (sel = self.selectors[options[:name]])
        sel.options[:doc], sel.options[:page] = options[:doc], options[:page]
      else
        sel = Gruba::Selector.new(options)
        self.selectors[options[:name]] = sel
      end
      sel.perform
    end

    def set_url(url)
      uri = url.is_a?(URI) ? url : URI.parse(url)
      if uri.host
        current_host = uri.host
      else
        uri.scheme = 'http'
        uri.host = current_host
      end
      uri.to_s
    end

    def agent
      @agent ||= WWW::Mechanize.new
    end
  end
end
