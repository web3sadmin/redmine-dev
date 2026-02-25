# Make Rails 7 behave like Rails 4 for secret_key_base
module Rails
  class Application
    class Configuration
      alias_method :original_secret_key_base, :secret_key_base
      
      def secret_key_base
        @manual_secret_key_base || original_secret_key_base
      end
      
      def secret_key_base=(value)
        @manual_secret_key_base = value.to_s
      end
    end
  end
end

# Set it manually
Rails.application.config.secret_key_base = ENV['SECRET_KEY_BASE'] || SecureRandom.hex(64)
