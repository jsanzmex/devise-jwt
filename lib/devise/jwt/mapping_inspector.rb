# frozen_string_literal: true

module Devise
  module JWT
    # Inspect and extract information from a Devise mapping
    class MappingInspector
      attr_reader :scope, :mapping

      def initialize(scope)
        @scope = scope
        @mapping = Devise.mappings[scope]
        puts "SKIP SESSIONS PRESENT: #{JWT.config.to_json}"
      end

      def skip_sessions?
        JWT.config.skip_sessions
      end

      def jwt?
        mapping.modules.member?(:jwt_authenticatable)
      end

      def session?
        routes?(:session)
      end

      def registration?
        routes?(:registration)
      end

      def model
        mapping.to
      end

      # :reek:FeatureEnvy
      def path(name)
        prefix, scope, request = path_parts(name)
        [prefix, scope, request].delete_if do |item|
          !item || item.empty?
        end.join('/').prepend('/').gsub('//', '/')
      end

      # :reek:ControlParameter
      def methods(name)
        method = case name
                 when :sign_in      then 'POST'
                 when :sign_out     then sign_out_via
                 when :registration then 'POST'
                 end
        Array(method)
      end

      def formats
        puts "#{JWT.config.request_formats}"
        JWT.config.request_formats[scope] || default_formats
      end

      private

      def path_parts(name)
        prefix = mapping.instance_variable_get(:@path_prefix)
        path = mapping.path
        path_name = mapping.path_names[name]
        [prefix, path, path_name]
      end

      def routes?(name)
        mapping.routes.member?(name)
      end

      def sign_out_via
        Array(mapping.sign_out_via).map do |method|
          method.to_s.upcase
        end
      end

      def default_formats
        [nil]
      end
    end
  end
end
