module Lotus
  module Action
    # Rack integration API
    #
    # @since 0.1.0
    module Rack
      SESSION_KEY           = 'rack.session'.freeze
      DEFAULT_RESPONSE_CODE = 200
      DEFAULT_RESPONSE_BODY = []

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        # Use a Rack middleware as a before callback.
        #
        # The middleware will be used as it is, no matter if it's a class or an
        # instance. If it needs to be initialized, please do it before to pass
        # it as the argument of this method.
        #
        # At the runtime, the middleware be invoked with the raw Rack env.
        #
        # Multiple middlewares can be employed, just by using multiple times
        # this method.
        #
        # @param [#call] A Rack middleware
        #
        # @since 0.2.0
        #
        # @see Lotus::Action::Callbacks::ClassMethods#before
        #
        # @example Class Middleware
        #   require 'lotus/controller'
        #
        #   class SessionsController
        #     include Lotus::Controller
        #
        #     action 'Create' do
        #       use OmniAuth
        #
        #       def call(params)
        #         # ...
        #       end
        #     end
        #   end
        #
        # @example Instance Middleware
        #   require 'lotus/controller'
        #
        #   class SessionsController
        #     include Lotus::Controller
        #
        #     action 'Create' do
        #       use XMiddleware.new('x', 123)
        #
        #       def call(params)
        #         # ...
        #       end
        #     end
        #   end
        def use(middleware)
          before do |params|
            middleware.call(params.env)
          end
        end
      end

      protected
      # Sets the HTTP status code for the response
      #
      # @param status [Fixnum] an HTTP status code
      # @return [void]
      #
      # @since 0.1.0
      #
      # @example
      #   require 'lotus/controller'
      #
      #   class Create
      #     include Lotus::Action
      #
      #     def call(params)
      #       # ...
      #       self.status = 201
      #     end
      #   end
      def status=(status)
        @_status = status
      end

      # Sets the body of the response
      #
      # @param body [String] the body of the response
      # @return [void]
      #
      # @since 0.1.0
      #
      # @example
      #   require 'lotus/controller'
      #
      #   class Show
      #     include Lotus::Action
      #
      #     def call(params)
      #       # ...
      #       self.body = 'Hi!'
      #     end
      #   end
      def body=(body)
        body   = Array(body) unless body.respond_to?(:each)
        @_body = body
      end

      # Gets the headers from the response
      #
      # @return [Hash] the HTTP headers from the response
      #
      # @since 0.1.0
      #
      # @example
      #   require 'lotus/controller'
      #
      #   class Show
      #     include Lotus::Action
      #
      #     def call(params)
      #       # ...
      #       self.headers            # => { ... }
      #       self.headers.merge!({'X-Custom' => 'OK'})
      #     end
      #   end
      def headers
        @headers
      end

      # Returns a serialized Rack response (Array), according to the current
      #   status code, headers, and body.
      #
      # @return [Array] the serialized response
      #
      # @since 0.1.0
      # @api private
      #
      # @see Lotus::Action::Rack::DEFAULT_RESPONSE_CODE
      # @see Lotus::Action::Rack::DEFAULT_RESPONSE_BODY
      # @see Lotus::Action::Rack#status=
      # @see Lotus::Action::Rack#headers
      # @see Lotus::Action::Rack#body=
      def response
        [ @_status || DEFAULT_RESPONSE_CODE, headers, @_body || DEFAULT_RESPONSE_BODY.dup ]
      end
    end
  end
end
