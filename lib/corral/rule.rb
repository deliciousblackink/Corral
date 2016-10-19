module Corral
  # Rule class representing actions doable on a subject.
  # @!visibility private
  class SubjectRule
    def initialize
      @actions = {}
    end

    # Add a granting ACL for a particular action.
    #
    # @param action [symbol] The action.
    # @param block An optional block for granularity.
    def add_grant(action, block)
      @actions[action] = (block || true)
    end

    # Add a denying ACL for a particular action.
    #
    # @param action [symbol] The action.
    # @param block An optional block for granularity.
    def add_deny(action, block)
      @actions[action] = (block || false)
    end

    # Return whether or not an object can perform a particular action on a subject
    # @param action [Symbol] The action.
    # @param subject [Object] The subject.
    # @param args [Hash] Variable arguments for more granular matching.
    # @return [Boolean] True or false.
    def authorized?(action, subject, args)
      block = @actions[:manage] || @actions[action]
      return false unless block
      return true if block == true
      return !!block.call(*[subject, *args])
    end
  end

  # Fake rule representing nothing matched a subject when looking up its ability.
  # @!visibility private
  class NullRule # :nodoc:
    def self.authorized?(*)
      false
    end
  end
end
