module Corral
  module ControllerAdditions
    module ClassMethods
      # Add this to a controller to ensure it performs authorization through +authorized+! or +authorize_resource+ call.
      # If neither of these authorization methods are called, a Corral::AuthorizationNotPerformed exception will be raised.
      # This can be placed in ApplicationController to ensure all controller actions do authorization.
      def check_authorization(options = {})
        self.after_action(options.slice(:only, :except)) do |controller|
          next if controller.instance_variable_defined?(:@_authorized)
          next if options[:if] && !controller.send(options[:if])
          next if options[:unless] && controller.send(options[:unless])
          raise AuthorizationNotPerformed, "This action failed the check_authorization because it did not authorize a resource. Add skip_authorization_check to bypass this check."
        end
      end

      # Call this in the class of a controller to skip the check_authorization behavior on the actions.
      # Any arguments are passed to the +before_action+ called.
      def skip_authorization_check(*args)
        self.before_action(*args) do |controller|
          controller.instance_variable_set(:@_authorized, true)
        end
      end
    end

    def self.included(base)
      base.extend ClassMethods
      base.helper_method :can?, :cannot?, :current_ability if base.respond_to? :helper_method
    end

    # Raises a Corral::AccessDenied exception if the current_ability cannot
    # perform the given action. This is usually called in a controller action or
    # before filter to perform the authorization.
    #
    # A :message option can be passed to specify a different message.
    #
    # You can rescue from the exception in the controller to customize how unauthorized
    # access is displayed to the user.
    #
    # See the load_and_authorize_resource method to automatically add the authorize! behavior
    # to the default RESTful actions.
    def authorize!(*args)
      @_authorized = true
      current_ability.authorize!(*args)
    end

    # Creates and returns the current user's ability and caches it. If you
    # want to override how the Ability is defined then this is the place.
    # Just define the method in the controller to change behavior.
    #
    # Notice it is important to memoize the ability object so it is not
    # recreated every time.
    def current_ability
      @current_ability ||= ::Ability.new(current_user)
    end

    # Use in the controller or view to check the user's permission for a given action
    # and object.
    #
    # This simply calls "can?" on the current_ability. See Ability#can?.
    def can?(*args)
      current_ability.can?(*args)
    end

    # Convenience method which works the same as "can?" but returns the opposite value.
    #
    def cannot?(*args)
      current_ability.cannot?(*args)
    end
  end
end

if defined? ActionController::Base
  ActionController::Base.class_eval do
    include Corral::ControllerAdditions
  end
end
