module Corral
  # A general exception
  class Error < StandardError; end

  # Raised when using check_authorization without calling authorize!
  class AuthorizationNotPerformed < Error; end

  # This error is raised when a user isn't allowed to access a given controller action.
  class AccessDenied < Error; end
end
