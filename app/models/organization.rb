class Organization < ActiveRecord::Base
  has_many :bidders, :dependent => :destroy
  has_many :agreements, :dependent => :destroy
  has_many :competitors, :dependent => :destroy

  belongs_to :dataset
  
  attr_accessible :id,
      :dataset_id,
      :organization_url,
      :code,
      :name,
      :country,
      :org_type,
      :is_bidder,
      :is_procurer,
      :city,
      :phone_number,
      :fax_number,
      :email,
      :webpage,
      :address,
      :translation

  validates :organization_url, :presence => true
  
  scope :order_by_name, order("name desc")
  scope :recent, order("name desc").limit(5)
  
  # number of items per page for pagination
	self.per_page = 20
  
  def getTranslations()
    translations = self.translation.split("#")
    return translations
  end

  def saveTranslations( wordList )
    translationString = ""
    wordList.each do |word|
      translationString += word + "#"
    end
    self.translation = translationString
    self.save
  end
end
