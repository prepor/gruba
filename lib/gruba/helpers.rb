module Gruba::Helpers
  class << self
    # options[:form]
    # options[:captcha_field]
    # options[:bot] => { :jid, :password }
    # options[:receiver]
    # options[:captcha]
    def captcha_jabber(options = {})
      Gruba.with_rescues false do
        im = Jabber::Simple.new(options[:bot][:jid], options[:bot][:password])
        im.deliver(options[:receiver], options[:captcha])
        @answer = nil
        while !@answer
          if im.received_messages?
            im.received_messages { |msg| @answer = msg.body if msg.type == :chat }
          end
        end
        options[:form].response = @answer
        options[:form].submit
      end
    end
  end
end

