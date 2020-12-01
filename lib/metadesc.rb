require 'rack'

module Rack
  module MetaDesc

    def self.new(*args)
      App.new(*args)
    end

    class App

      def initialize()
        @app = app
      end

      def call(env)
      end

    end

  end
end
