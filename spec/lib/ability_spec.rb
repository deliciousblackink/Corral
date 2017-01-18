require 'spec_helper'

class AbilityModel
  include Corral::Ability
end
class ActionSubject; end

RSpec.describe Corral::Ability do
  subject { AbilityModel.new }

  describe '#allow_anything!' do
    it 'allows any action' do
      subject.allow_anything!
      expect(subject.can? :perform_action, ActionSubject).to be_truthy
    end
  end

  describe '#can (#can?)' do
    it 'allows permitted actions' do
      subject.can :perform_action, ActionSubject
      expect(subject.can? :perform_action, ActionSubject).to be_truthy
    end

    it 'denies anything that is not permitted' do
      expect(subject.can? :perform_action, ActionSubject).to be_falsey
    end

    it 'allows actions to be whitelisted with :manage' do
      subject.can :manage, ActionSubject
      expect(subject.can? :manage, ActionSubject).to be_truthy
      expect(subject.can? :perform_action, ActionSubject).to be_truthy
    end

    context 'with blocks' do
      it 'allows access to be specified dynamically' do
        subject.can(:perform_action, ActionSubject) { @state }

        @state = false
        expect(subject.can? :perform_action, ActionSubject).to be_falsey
        @state = true
        expect(subject.can? :perform_action, ActionSubject).to be_truthy
      end

      it 'passes the subject to the block' do
        subject.can :perform_action, ActionSubject do |action_subject|
          expect(action_subject).to be ActionSubject
        end
        subject.can? :perform_action, ActionSubject
      end

      it 'accepts an instance of the subject to be passed to the block' do
        instance = ActionSubject.new
        subject.can :perform_action, ActionSubject do |action_subject|
          expect(action_subject).to be instance
        end
        subject.can? :perform_action, instance
      end

      it 'accepts arbitrary values to be passed to the block' do
        value1, value2, value3 = [1, 'hello', true]
        subject.can :perform_action, ActionSubject do |_subject, v1, v2, v3|
          expect(v1).to eq value1
          expect(v2).to eq value2
          expect(v3).to eq value3
        end
        subject.can? :perform_action, ActionSubject, value1, value2, value3
      end
    end
  end

  describe '#cannot' do
    context 'specified after #can' do
      it 'overrides single definitions' do
        subject.can :perform_action, ActionSubject
        subject.cannot :perform_action, ActionSubject
        expect(subject.can? :perform_action, ActionSubject).to be_falsey
      end

      it 'overrides :manage' do
        subject.can :manage, ActionSubject
        subject.cannot :destroy, ActionSubject

        expect(subject.can? :manage, ActionSubject).to be_truthy
        expect(subject.can? :perform_action, ActionSubject).to be_truthy
        expect(subject.can? :destroy, ActionSubject).to be_falsey
      end
    end

    context 'specified after #allow_anything!' do
      it 'does not restrict access' do
        subject.allow_anything!
        subject.cannot :perform_action, ActionSubject

        expect(subject.can? :perform_action, ActionSubject).to be_truthy
      end
    end

    it 'does not accept blocks' do
      expect { subject.cannot(:manage, ActionSubject) { true } }.to raise_error(ArgumentError, '#cannot does not support granular matching by block.')
    end

    it 'does not accept additional values' do
      expect { subject.cannot(:manage, ActionSubject, 'value') }.to raise_error(ArgumentError)
    end
  end
end
