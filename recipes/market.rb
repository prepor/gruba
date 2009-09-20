# Граббинг всего сайта

#"http://market.yandex.ru/".gruba do  
  #get :categories, ".subcat" do    
    #get "a" do      
      #unless body == '...'
        #link(attr[:href]) do
        #link :text => "\n\t\t\t\tПосмотреть все модели\n\t\t\t" do
          #get :item_links, "body" do
            #get "a.b-offers__name" do
              #link(attr[:href]) do
                #item! :title => get("#global-model-name").body, :reviews => [], :params => {}
                #get "#main-spec-cont tr" do
                  #item[:params][get("td[1]").text] = get("td[2]").text if get("td[1]").text[0] != 194
                #end
                #link :text => 'Обзоры' do
                  #get ".b-reviews .item a" do
                    #item[:reviews] << attr[:href]
                  #end 
                #end
              #end
            #end
            #pages_links :section, "#pager.numbers a" do
              #get :item_links, "body"
            #end
          #end          
        #end
        #get :categories, ".supcat"          
        #end
      #end
    #end
  #end  
#end

# Одна категория
"http://market.yandex.ru/guru.xml?CMD=-RR=9,0,0,0-VIS=160-CAT_ID=137555-EXC=1-PG=10&hid=90560".gruba do
  get :item_links, "body" do
    get "a.b-offers__name" do
      link(attr[:href]) do
        item! :title => get("#global-model-name").body, :reviews => [], :params => {}
        get "#main-spec-cont tr" do
          item[:params][get("td[1]").text] = get("td[2]").text if get("td[1]").text[0] != 194
        end
        link :text => 'Обзоры' do
          get ".b-reviews .item a" do
            item[:reviews] << attr[:href]
          end 
        end
      end
    end
    pages_links :section, "#pager.numbers a" do
      get :item_links, "body"
    end
  end     
end


Gruba.add_rescue WWW::Mechanize::ResponseCodeError do |e|
  if e.response_code == '403'
    Gruba::Helpers.captcha_jabber :form => e.page.forms.first,
                                  :captcha_field => :response,
                                  :captcha => (e.page.search("img").detect {|i| i[:src] =~ /image/ })[:src],
                                  :bot => { :jid => 'gruba_bot@jabber.ru', :password => 'qwezxc' },
                                  :receiver => 'rudenkoco@gmail.com'
  else
    throw :halt
  end
end

Gruba.on_finish do
  pp Gruba.data[:item].map{|v| v[:reviews]}.flatten.map {|v| URI.parse(v).host }.uniq
end
