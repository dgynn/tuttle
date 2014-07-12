module Tuttle
  class Engine < ::Rails::Engine
    isolate_namespace Tuttle

    attr_accessor :reload_needed

    initializer "tuttle.assets.precompile" do |app|
      app.config.assets.precompile += %w(tuttle/application.css tuttle/application.js )
    end

    initializer :tuttle_track_reloads, group: :all do
      ActionDispatch::Reloader.to_prepare do
        Rails.logger.warn('Tuttle: ActionDispatch::Reloader called to_prepare')
        Tuttle::Engine.reload_needed = true
      end
    end
  end

end
