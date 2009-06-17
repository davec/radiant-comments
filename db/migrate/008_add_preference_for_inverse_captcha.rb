class AddPreferenceForInverseCaptcha < ActiveRecord::Migration
  def self.up
    unless Radiant::Config['comments.inverse_captcha_required?']
      Radiant::Config.create(:key => 'comments.inverse_captcha_required?', :value => false)
    end
  end
  
  def self.down
    # not necessary
  end
end

