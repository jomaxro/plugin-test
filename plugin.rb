# name: staff-forum-plugin
# about: Adds a route for staff corner to mark topics as read
# version: 1.0.0
# authors: Joshua Rosenfeld
# url: https://github.com/jomaxro/plugin-test/
enabled_site_setting :mark_read_enabled
after_initialize do
    module ::StaffForumsMarkRead
        class Engine < ::Rails::Engine
            engine_name "staff_forums_mark_read"
            isolate_namespace StaffForumsMarkRead
        end
    end
    
    require_dependency File.expand_path('../app/controllers/staff_corner_controller.rb', __FILE__)
    
    require_dependency 'application_controller'
    class StaffForumsMarkRead::MarkReadController < ::ApplicationController
        before_action :ensure_plugin_enabled
        def ensure_plugin_enabled
            raise Discourse::InvalidAccess.new('Staff Forums Mark Read plugin is not enabled') if !SiteSetting.mark_read_enabled
        end
    end
    
    Discourse::Application.routes.append do
        get "staffcorner/mark-read/:pulseUserId/:topicId" => "staffcorner#mark_read"
    end
end
