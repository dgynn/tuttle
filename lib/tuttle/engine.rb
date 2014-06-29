module Tuttle
  class Engine < ::Rails::Engine
    isolate_namespace Tuttle

    initializer "tuttle.assets.precompile" do |app|
      app.config.assets.precompile += %w(tuttle/application.css tuttle/application.js )
    end

  end
end
