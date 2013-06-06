class DialogController < ApplicationController
  def show_white_list
    orgID = params[:id]
    @item = WhiteListItem.where(:organization_id => orgID).first
  end
  
  def show_black_list
    orgID = params[:id]
    @item = BlackListItem.where(:organization_id => orgID).first
    if @item.tender_id
      @tenderDB = Tender.where(:tender_registration_number => @item.tender_id).first
    end
  end

  def show_complaint
    complaintID = params[:id]
    @item = Complaint.find(complaintID)
    @tenderName = Tender.find(@item.tender_id).tender_registration_number
    @orgName = Organization.find(@item.organization_id).name
  end
end
