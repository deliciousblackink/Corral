module Corral
  module Ability
    # Check whether the object can perform an action on a subject.
    #
    # @overload can?(action, subject)
    #   @param action [Symbol] The action, represented as a symbol.
    #   @param subject [Object] The subject.
    # @overload can?(action, subject, args)
    #   @param action [Symbol] The action, represented as a symbol.
    #   @param subject [Object] The subject.
    #   @param args [Hash] Variable arguments for more granular matching.
    # @return [Boolean] True or false.
    def can?(action, subject, *args)
      return true if @allow_anything
      lookup_rule(subject).authorized?(action, subject, args)
    end

    # Inverse of #can?.
    #
    # @see #can?
    def cannot?(*args)
      not can?(*args)
    end

    # Adds a granting-access rule.
    #
    # @param action [Symbol] The action, represented as a symbol.
    # @param subject [Object] The subject.
    # @param block [Hash] Variable arguments for more granular matching.
    def can(action, subject, &block)
      rule_for(subject).add_grant(action, block)
    end

    # Adds a denying-access rule. Overrides previous #can definitions.
    #
    # @param action [Symbol] The action, represented as a symbol.
    # @param subject [Object] The subject.
    def cannot(action, subject)
      raise ArgumentError, '#cannot does not support granular matching by block.' if block_given?
      rule_for(subject).add_deny(action)
    end

    # Allow the object to perform any action on any subject.
    # This overrides any #cannot rules.
    #
    def allow_anything!
      @allow_anything = true
    end

    # Check whether the object has authorization to perform the
    # action it intends to on the subject. Raise AccessDenied
    # if it doesn't.
    #
    # @param action [Symbol] The intended action.
    # @param subject [Object] The subject of the action.
    # @raise [AccessDenied] if the object does not have permission.
    def authorize!(action, subject, *args)
      raise AccessDenied if cannot?(action, subject, *args)
    end

    protected

    # Subjects hash.
    def subjects
      @subjects ||= {}
    end

    # Find or create a new rule for the specified subject.
    #
    # @param subject [Object] The subject.
    def rule_for(subject)
      subjects[subject] ||= SubjectRule.new
    end

    # Lookup a rule for a particular subject.
    #
    # @param subject [Object] The subject.
    def lookup_rule(subject)
      case subject
      when Symbol, Module
        subjects[subject] || subjects[:all] || NullRule
      else
        subjects[subject.class] || NullRule
      end
    end
  end
end
