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

  def save_risky_group
    codes = params[:codes].split(",")
    category = params[:category]
    cpvGroup = CpvGroup.find(2)
    cpvGroup.tender_cpv_classifiers.delete_all
    
    codes.each do |code|
      cpv = TenderCpvClassifier.where( :cpv_code => code.to_i ).first
      cpvGroup.tender_cpv_classifiers << cpv
    end
    cpvGroup.save

    redirect_to :controller => :cpv_tree, :action =>:showRiskyCPVs
  end

end
