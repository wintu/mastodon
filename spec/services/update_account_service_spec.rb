require 'rails_helper'

RSpec.describe UpdateAccountService, type: :service do
  subject { UpdateAccountService.new }

  describe 'switching form locked to unlocked accounts' do
    let(:account) { Fabricate(:account, locked: true) }
    let(:alice)   { Fabricate(:user, email: 'alice@example.com', account: Fabricate(:account, username: 'alice')).account }
    let(:bob)     { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, username: 'bob')).account }
    let(:eve)     { Fabricate(:user, email: 'eve@example.com', account: Fabricate(:account, username: 'eve')).account }

    before do
      bob.touch(:silenced_at)
      account.mute!(eve)

      FollowService.new.call(alice, account)
      FollowService.new.call(bob, account)
      FollowService.new.call(eve, account)

      subject.call(account, { locked: false })
    end

    it 'auto-accepts pending follow requests' do
      expect(alice.following?(account)).to be true
      expect(alice.requested?(account)).to be false
    end

    it 'does not auto-accept pending follow requests from silenced users' do
      expect(bob.following?(account)).to be false
      expect(bob.requested?(account)).to be true
    end

    it 'auto-accepts pending follow requests from muted users so as to not leak mute' do
      expect(eve.following?(account)).to be true
      expect(eve.requested?(account)).to be false
    end
  end
end
