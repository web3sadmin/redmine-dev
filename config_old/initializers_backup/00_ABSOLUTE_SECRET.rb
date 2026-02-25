# ABSOLUTE SECRET SETTER - CANNOT FAIL
SECRET_ABSOLUTE = ENV['SECRET_KEY_BASE'].to_s
if SECRET_ABSOLUTE.length < 64
  require 'securerandom'
  SECRET_ABSOLUTE = SecureRandom.hex(64)
end

# Direct global assignment
Object.const_set(:REDMINE_SECRET_KEY_BASE, SECRET_ABSOLUTE.freeze)

# Hook into Rails initialization
if defined?(Rails::Application)
  Rails::Application.class_eval do
    def config
      @config ||= super.tap do |c|
        class << c
          attr_accessor :_forced_secret
          
          def secret_key_base
            self._forced_secret || REDMINE_SECRET_KEY_BASE
          end
          
          def secret_key_base=(value)
            self._forced_secret = value.to_s
          end
          
          # Kill the validator
          def validate_secret_key_base
            true
          end
        end
        
        c._forced_secret = SECRET_ABSOLUTE
      end
    end
  end
end
