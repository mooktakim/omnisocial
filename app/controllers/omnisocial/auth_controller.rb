module Omnisocial
  class AuthController < ApplicationController
  
    unloadable
  
    def new
      if current_user?
        flash[:notice] = 'You are already signed in. Please sign out if you want to sign in as a different user.'
        redirect_to(root_path)
      end
    end
  
    def callback    
      auth = request.env['omniauth.auth'] || request.env['rack.auth']
      account = case auth['provider']
                when 'twitter'
                  Omnisocial::TwitterAccount.find_or_create_from_auth_hash auth
                when 'facebook'
                  Omnisocial::FacebookAccount.find_or_create_from_auth_hash auth
                end

      if self.current_user
        account.user = self.current_user
        account.save
        flash[:message] = "You have added #{auth['provider']} account successfully."
      else
        self.current_user = account.find_or_create_user
        flash[:message] = 'You have logged in successfully.'
      end

      # Add email
      if auth['extra'].present? and
        auth['extra']['user_hash'].present? and
        auth['extra']['user_hash']['email'].present?
        account.user.add_email auth['extra']['user_hash']['email']
        account.save
      end

      redirect_back_or_default(root_path)
    end
  
    def failure
      flash[:error] = "We had trouble signing you in. Did you make sure to grant access? Please select a service below and try again."
      render :action => 'new'
    end
  
    def destroy
      logout!
      redirect_to(root_path)
    end
  end
end
