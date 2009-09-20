module Gruba
  class Element
    attr_accessor :doc, :parent, :data
    def initialize(doc, parent, &block)
      self.doc, self.parent, self.data = doc, parent, {}
      self.instance_eval(&block) if block
    end

    def get(*argv, &block)
      if block || argv.size > 1
        options = { :parent => self, :doc => doc, :proc => block }
        options[argv[0].is_a?(String) ? :selector : :name] = argv[0]
        options[:selector] ||= argv[1]
        Gruba.current_session.selector(options)
      else
        res = doc.search(argv[0]).first
        res ? Gruba::Element.new(res, self) : nil
      end
    end
    alias_method :g, :get

    def method_missing(name, argv = nil)
      val = if name.to_s.match(/(.+)!$/)
              new_data($1.to_sym, argv)
            else
              get_data(name)
            end

      if val
        val
      else
        super
      end
    end

    def attr
      doc
    end

    def new_data(name, params)
      data[name] ||= []
      data[name] << params
      Gruba.current_session.new_data_element(name, params)
    end

    def get_data(name)
      if data[name]
        data[name].last
      elsif parent
        parent.get_data(name)
      else
        nil
      end
    end

    def get_attribute(name)
      doc[name.to_s]
    end

    def data_element(name, params)
      Gruba.current_session.data_element(name.to_s, params, page)
    end    

    def body
      Iconv.iconv('utf8', Gruba.current_session.encoding, doc.inner_html) * ''
    end

    def text
      Iconv.iconv('utf8', Gruba.current_session.encoding, doc.inner_text) * ''
    end

    def link(options, &block)
      filter = if options.is_a?(Hash) && options[:text]
                 lambda { |l| l.inner_html == options[:text] }
               else
                 options
               end
      link = if filter.is_a? Proc
              res = doc.search('a').detect(&filter)
              res && res[:href] ? res[:href] : nil
             elsif filter.is_a? String
               filter
             else
               nil
             end
      Gruba.current_session << Gruba::Page.new(:url => link, :proc => block, :parent => self) if link
    end

    def pages_links(pages_id, selector, &block)
      doc.search(selector).each do |e|
        link(e[:href], &block) unless Gruba.current_session.queue_hash[e[:href]]
      end
    end
  end

end
