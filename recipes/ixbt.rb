require 'activesupport'
#  mobilepc sw probiz ds maclife data printers projector dv md platform pa nw dp
%w{3dv}.each do |section| 
  "http://www.ixbt.com/#{section}/archive/".gruba do
    get ".spoiler-body" do
      if attr[:id] != 'div_news' && attr[:id] != 'div_conference'
        get "a" do 
        review! :title => body
        link attr[:href] do
          review[:body] = get("center[2]").try :body
        end
        end
      end
    end
  end
end

Gruba.interval = 1
Gruba.encoding = 'cp1251'

Gruba.on_finish do
  pp Gruba.data[:review].map { |v| v[:title] }
end

Gruba.add_rescue WWW::Mechanize::ResponseCodeError, :retry => false do |e|
  if e.response_code == '404'
    Gruba.logger.info "404 error"
  end
end

