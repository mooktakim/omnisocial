class ActionController::Base
  def self.require_user(options = {})
    raise Exception, "require_user cannot be called on ActionController::Base. Only it's subclasses" if self ==  ActionController::Base
    prepend_before_filter :require_user, options
  end
  
  helper_method :current_user, :current_user?

  protected
  
  # Filters
  
  def require_user
    current_user.present? || deny_access
  end
  
  # Utils
  
  def store_location(url)
    path = URI.parse(url).path.downcase
    if !request.get? or ['/login', '/logout'].include?(path) or path.match(/^\/auth\//i)
      session[:return_to] = nil
    else
      session[:return_to] = url
    end
  rescue
    session[:return_to] = nil
  end
  
  def deny_access
    store_location(request.fullpath)
    redirect_to login_path
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
  def current_user
    @current_user ||= (session_login || cookie_login)
  rescue
    logout!
  end
  
  def session_login
    User.find(session[:user_id]) rescue nil
  end
  
  def cookie_login
    u = User.find_with_remember_token(cookies.signed[:remember_token])
    current_user = u if u
    u
  end
  
  def current_user?
    !!current_user
  end
  
  def current_user=(user)
    user.tap do |user|
      session[:user_id] = user.id
      cookies.permanent.signed[:remember_token] = user.remember
    end
  end
  
  def logout!
    @current_user = nil
    session.delete(:user_id)
    session.delete(:return_to)
    cookies.delete(:remember_token)
  end
  
end
