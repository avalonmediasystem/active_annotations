if defined?(Rails)
  module ActiveAnnotations  
    class Engine < Rails::Engine
      config.autoload_paths += Dir["#{config.root}/app/models/**/"]

      engine_name 'active_annotations'
    end
  end
end
