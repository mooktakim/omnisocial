module Omnisocial
  class User < ActiveRecord::Base
    has_many :login_accounts, :class_name => 'Omnisocial::LoginAccount', :dependent => :destroy
    accepts_nested_attributes_for :login_accounts
    delegate :login, :name, :picture_url, :account_url, :to => :login_account

    has_many :email_addresses, :dependent => :destroy
    accepts_nested_attributes_for :email_addresses

    def add_email(email)
      self.email_addresses.create(:email => email) unless self.email_addresses.exists?(:email => email.downcase)
    end

    def email
      self.email_addresses.first.try(:email)
    end

    def name
      login_account.try(:name) || email.to_s.split("@").first.try(:capitalize) || "Unknown"
    end

    def login
      login_account.try :login
    end

    def picture_url
      login_account.try(:picture_url) || 'http://gravatar.com/avatar/0'
    end

    def account_url
      login_account.try :account_url
    end

    def login_account
      # Prefer FB account more than Twitter
      account = login_accounts.detect{|l| l.kind_of? Omnisocial::FacebookAccount }
      account ||= login_accounts.first
    end

    def has_twitter?
      !!twitter_login
    end

    def twitter_login
      @twitter_login ||= login_accounts.detect{|l| l.kind_of? Omnisocial::TwitterAccount }
    end
    
    def twitter_logins
      @twitter_logins ||= login_accounts.select{|l| l.kind_of? Omnisocial::TwitterAccount }
    end

    def has_facebook?
      !!facebook_login
    end

    def facebook_login
      @facebook_login ||= login_accounts.detect{|l| l.kind_of? Omnisocial::FacebookAccount }
    end
    
    def facebook_logins
      @facebook_logins ||= login_accounts.select{|l| l.kind_of? Omnisocial::FacebookAccount }
    end
  
    def to_param
      if !self.login.include?('profile.php?')
        "#{self.id}-#{self.login.gsub('.', '-')}"
      else
        self.id.to_s
      end
    end
  
    def remember
      update_attributes(:remember_token => ::BCrypt::Password.create("#{Time.now}-#{self.login_account.type}-#{self.login}")) unless new_record?
    end
  
    def forget
      update_attributes(:remember_token => nil) unless new_record?
    end
  end
end
