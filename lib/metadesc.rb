require 'rack'
require 'nokogiri'

module Rack
  module MetaDesc

    def self.new(*args)
      App.new(*args)
    end

    class App

      def initialize(app, rules = {}, fallback_description = nil, site_name = nil)
        @app = app
        @rules = {title: 'title', description: 'p'}.merge rules
        @fallback_description = fallback_description
        @site_name = site_name
      end

      def call(env)

        request = ::Rack::Request.new(env)
        response = @app.call(env)
        status, headers, body = response

        unless html?(headers)
          return response
        end

        html = Nokogiri::HTML(body[0])

        head = html.css('head').first
        return response if head.nil?

        content = get_description(html)

        if content.nil?
          return response if @fallback_description.nil?

          description = @fallback_description
        else
          description = content.content
        end

        meta = <<-END.gsub(/^\s+\|/, '')
          |<meta name="description" content="#{description}" />
          |<meta property="og:description" content="#{description}" />
          |<meta property="og:url" content="#{request.url}" />
          |<meta name="theme-color" content="#3498DB">
          |<meta property="og:type" content="website" />
          |<meta name="twitter:card" content="summary_large_image">
        END

        if (image = html.css('img').first) && ! image.nil?
          if request.base_url && image['src']
            meta += %{<meta property="og:image" content="#{request.base_url + image['src']}" />}
          end
        end

        
        if title = get_title(html)
          meta += %{<meta name="og:title" content="#{title}" />} if !title.nil? && !title.empty?
        end
        
        unless @site_name.nil?
          meta += %{<meta name="og:site_name" content="#{@site_name}" />}
        end

        head.add_next_sibling(meta)

        body[0] = html.to_html
        headers['Content-Length'] = get_length(body[0])

        return response
      end

      private

      def html?(headers)
        !!(headers['Content-Type'] =~ /text\s*\/\s*html\s*(?:;|$)/)
      end

      def get_description(html)
        html.css(@rules[:description]).first
      end

      def get_title(html)
        title = html.css(@rules[:title]).first
        return nil if title.nil?

        title.content
      end

      def get_length(html)
        html.bytesize.to_s
      end

    end

  end
end
