module Omnisocial
  class FacebookAccount < LoginAccount
    def assign_account_info(auth_hash)
      self.remote_account_id  = auth_hash['uid']
      self.login              = auth_hash['user_info']['nickname']
      self.name               = auth_hash['user_info']['name']
      self.user_hash          = auth_hash['extra']['user_hash']
      if auth_hash['credentials'].present? and auth_hash['credentials']['token'].present?
        self.token = auth_hash['credentials']['token']
      end
    end
  
    def account_url
      "http://facebook.com/#{self.login}"
    end
  
    def picture_url
      if self.login.include?('profile.php')
        "https://graph.facebook.com/#{self.login.gsub(/[^\d]/, '')}/picture"
      else
        "https://graph.facebook.com/#{self.login}/picture"
      end
    end
  end
end
