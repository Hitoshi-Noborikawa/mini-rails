# frozen_string_literal: true

module MiniPack
  class Mapper
    module Resources
      class Resource
        attr_reader :name, :singular, :path

        def initialize(name)
          @name = name.to_s
          @singular = @name.singularize
          @path = "/#{@name}"
        end
      end

      def resources(resource_name)
        route = Resource.new(resource_name)

        get "#{route.path}", to: "#{route.name}#index"
        get "#{route.path}/new", to: "#{route.name}#new"
        post "#{route.path}", to: "#{route.name}#create"
        get "#{route.path}/:id", to: "#{route.name}#show"
        get "#{route.path}/:id/edit", to: "#{route.name}#edit"
        patch "#{route.path}/:id", to: "#{route.name}#update"
        delete "#{route.path}/:id", to: "#{route.name}#destroy"

        UrlHelpers.define_method("#{route.name}_path") { route.path }
        UrlHelpers.define_method("new_#{route.singular}_path") { "#{route.path}/new" }
        UrlHelpers.define_method("#{route.singular}_path") { |id| "#{route.path}/#{id}" }
        UrlHelpers.define_method("edit_#{route.singular}_path") { |id| "#{route.path}/#{id}/edit" }
      end

      def resource(resource_name)
        route = Resource.new(resource_name)

        get "#{route.path}/new", to: "#{route.name}#new"
        post "#{route.path}", to: "#{route.name}#create"
        get "#{route.path}", to: "#{route.name}#show"
        get "#{route.path}/edit", to: "#{route.name}#edit"
        patch "#{route.path}", to: "#{route.name}#update"
        delete "#{route.path}", to: "#{route.name}#destroy"

        UrlHelpers.define_method("new_#{route.singular}_path") { "#{route.path}/new" }
        UrlHelpers.define_method("#{route.singular}_path") { route.path }
        UrlHelpers.define_method("edit_#{route.singular}_path") { "#{route.path}/edit" }
      end
    end
  end
end
