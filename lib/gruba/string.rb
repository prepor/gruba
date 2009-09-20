module Gruba
  module String
    def gruba(&block)
      page = Gruba::Page.new(:url => self, :proc => block)
      Gruba.current_session << page
      page
    end
  end
end
