module Omnisocial
  class TwitterAccount < LoginAccount
    def assign_account_info(auth_hash)
      self.remote_account_id  = auth_hash['uid']
      self.login              = auth_hash['user_info']['nickname']
      self.picture_url        = auth_hash['user_info']['image']
      self.name               = auth_hash['user_info']['name']
      self.user_hash          = auth_hash['extra']['user_hash']
      if auth_hash['credentials'].present? and auth_hash['credentials']['token'].present?
        self.token = auth_hash['credentials']['token']
      end
      if auth_hash['credentials'].present? and auth_hash['credentials']['secret'].present?
        self.secret = auth_hash['credentials']['secret']
      end
    end
  
    def account_url
      "http://twitter.com/#{self.login}"
    end
  end
end
