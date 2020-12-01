require 'rack'
require 'nokogiri'

module Rack
  module MetaDesc

    def self.new(*args)
      App.new(*args)
    end

    class App

      def initialize(app, rule = 'p', fallback_description = nil)
        @app = app
        @rule = rule
        @fallback_description = fallback_description
      end

      def call(env)
        response = @app.call(env)
        status, headers, body = response

        unless html?(headers)
          return response
        end

        html = Nokogiri::HTML(body[0])

        head = html.css('head').first
        return response if head.nil?

        content = get_content(html)

        if content.nil?
          return response if @fallback_description.nil?

          description = @fallback_description
        else
          description = content.content
        end

        meta = "<meta name=\"description\" content=\"#{description}\">"

        head.add_next_sibling(meta)

        body[0] = html.to_html
        headers['Content-Length'] = get_length(body[0])

        return response
      end

      private

      def html?(headers)
        !!(headers['Content-Type'] =~ /text\s*\/\s*html\s*(?:;|$)/)
      end

      def get_content(html)
        html.css(@rule).first
      end

      def get_length(html)
        html.bytesize.to_s
      end

    end

  end
end
