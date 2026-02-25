# Assets configuration for Redmine
Rails.application.config.assets.paths << Rails.root.join('app', 'assets')
Rails.application.config.assets.paths << Rails.root.join('lib', 'assets')
Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets')
Rails.application.config.assets.paths << Rails.root.join('public')

# Redmine specific asset paths
if Rails.application.config.assets.redmine_extension_paths
  Rails.application.config.assets.redmine_extension_paths.each do |path|
    Rails.application.config.assets.paths << path if File.directory?(path)
  end
end

# Ensure assets are initialized
Rails.application.config.after_initialize do
  if Rails.application.assets.nil? && Rails.application.config.assets.enabled
    puts "Initializing assets pipeline..." if Rails.env.development?
    
    # Manually create assets environment
    require 'sprockets'
    
    env = Sprockets::Environment.new(Rails.root.to_s) do |env|
      env.logger = Rails.logger
      env.context_class.class_eval do
        include ::Sprockets::Helpers::RailsHelper
      end
    end
    
    # Add paths
    Rails.application.config.assets.paths.each do |path|
      env.append_path(path) if File.directory?(path)
    end
    
    Rails.application.instance_variable_set(:@assets, env)
  end
end
