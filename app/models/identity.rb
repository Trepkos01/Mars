class Identity < ActiveRecord::Base
  belongs_to :user
	
	validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider

  def self.find_for_oauth(auth)
    identity = find_or_create_by(uid: auth.uid, provider: auth.provider)
		identity.update_attributes(access_token: auth.credentials.token, access_secret: auth.credentials.secret)
		return identity
  end
end