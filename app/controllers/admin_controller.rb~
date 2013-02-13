class AdminController < ApplicationController
  before_filter :authenticate_user!
  before_filter :requires_admin

  def requires_admin
    if current_user.role != 'admin'
      redirect_to "/"
    end
  end

  def index
    @users = User.where(:role => "user")
  end

  def manageCPVs
    profileAccount = User.where(:role => "profile").first
    @userID = profileAccount.id
    @categories = profileAccount.cpvGroups 
  end

end
