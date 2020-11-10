module HAWM
  module PVA
    class Engine < ::Rails::Engine
      isolate_namespace PVA

      config.after_initialize do
        ::Discourse::Application.routes.append do
          mount PVA::Engine, at: "/"
        end
      end

      # this event run upon every request in development
      # hook to early event if need early access overrides
      config.to_prepare do
        # override Discourse core
        Dir.glob(Engine.root + "app/overrides/**/*_override*.rb").each do |c|
          require_dependency(c)
        end
      end

      config.generators do |g|
        g.test_framework :repec, fixture: false
      end
    end
  end
end
