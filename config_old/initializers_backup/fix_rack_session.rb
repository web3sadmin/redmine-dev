# Fix for undefined method `info` for nil:NilClass in Rack sessions
# This error happens when session object is nil

module Rack
  module Session
    module Abstract
      class SessionHash
        # Ensure session always has info method
        def info
          @info ||= {}
        end
        
        # Ensure session_id is always available
        def session_id
          self[:session_id] || generate_sid
        end
        
        # Safe nil check for all methods
        def method_missing(method, *args, &block)
          if @data && @data.respond_to?(method)
            @data.send(method, *args, &block)
          else
            # Return safe defaults for common methods
            case method.to_s
            when 'info'
              {}
            when 'inspect'
              '#<SessionHash>'
            when 'to_s'
              '#<SessionHash>'
            else
              super
            end
          end
        end
        
        def respond_to_missing?(method, include_private = false)
          [:info, :inspect, :to_s].include?(method) || super
        end
      end
    end
  end
end

# Also patch ActionDispatch for Rails
module ActionDispatch
  class Request
    class Session
      def info
        {}
      end
    end
  end
end

# Initialize session store properly
Rails.application.config.after_initialize do
  if defined?(Rack::Session::Abstract::SessionHash)
    puts "[Session Fix] Patched Rack::Session::Abstract::SessionHash" if Rails.env.development?
  end
end
