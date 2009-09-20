require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pp'
require 'uri'
require 'yaml'
require 'pathname'
require 'mechanize'
require 'logger'
require 'xmpp4r-simple'
require 'iconv'
require 'forwardable'
require 'logger'
$KCODE = 'u'

module Gruba
  require 'gruba/string'
  require 'gruba/element'
  require 'gruba/page'
  require 'gruba/session'
  require 'gruba/selector'
  require 'gruba/helpers'

 
  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::ERROR
  class << self
    extend Forwardable

    attr_accessor :rescues


    def logger
      @@logger
    end
    def current_session
      @session ||= Gruba::Session.new
    end
    def add_rescue(const, options = {}, &block)
      @rescues ||= []
      options[:const] = const
      options[:block] = block
      options[:retry] = true if options[:retry].nil?
      @rescues << options
    end

    def_delegators :current_session, :data, :encoding, :encoding=, :interval, :interval=, :on_finish

    def with_rescues(with_retry = true)
      catch :halt do
        begin
          yield
        rescue => e
          if (res = (rescues || []).detect { |v| e.class == v[:const] })
            res[:block].call(e)
            retry if with_retry && res[:retry]
          else
            raise e
          end
        end
      end
    end

    def cmd(options)
      @@logger = Logger.new(File.open(options[:logfile])) if options[:logfile]
      logger.level = Logger::INFO if options[:verbose]

      ARGV.each { |f| require f }
      Thread.abort_on_exception = true
      process_thread = Thread.new do
        Gruba.current_session.perform
      end
      unless options[:verbose]
        pretty_print
      end
      process_thread.join
    end

    def pretty_print
      STDOUT.sync = true
      while !Gruba.current_session.finished?
        print "Parsed pages: #{Gruba.current_session.perfomed_pages.size}, "
        print "pages in queue: #{Gruba.current_session.queue.size}, "
        print "data elements: #{Gruba.current_session.data_elements_counter}\r"
        sleep 0.5
      end
      puts ""
    end
  end
end

class String
  include Gruba::String
end
