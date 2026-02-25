# Fix for session 'info' method error
module Rack
  module Session
    module Abstract
      class SessionHash
        def info
          {}
        end
      end
    end
  end
end

# Simple session store
Rails.application.config.session_store :cookie_store,
  key: '_redmine_session',
  expire_after: 7.days
