# == Schema Information
#
# Table name: users
#
#  id                     :string          not null, primary key
#  user_name              :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default("0"), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  failed_attempts        :integer          default("0"), not null
#  unlock_token           :string
#  locked_at              :datetime
#  created_at             :datetime
#  updated_at             :datetime
#	 deleted_at							:datetime
#	 moderator							:boolean	
#
# Has many restaurants, meals, meal_recommendations, meal_additionals.

require 'securerandom'

class User < ActiveRecord::Base
	self.primary_key = 'id'
	
	TEMP_EMAIL_PREFIX = 'change@me'
  TEMP_EMAIL_REGEX = /\Achange@me/
	
	# Include devise modules.
	devise :database_authenticatable, :registerable,
		 :recoverable, :rememberable, :trackable, :validatable,
		 :confirmable, :lockable, :zxcvbnable, :omniauthable
	# Complete the below actions before creating a new user.
	before_create :generate_id, :generate_username, :set_default_provider
	before_update :set_default_provider
	# Users have many meals,restaurants, meal_recommendations, and meal_additionals.
	has_many :meals, :dependent => :destroy
	has_many :restaurants, :dependent => :destroy 
	has_many :meal_recommendations
	has_many :meal_additionals
	has_many :issues
	has_many :identities
	
	# Validation 
	validates_format_of :email, :without => TEMP_EMAIL_REGEX, on: :update
	
	# Taken loosely from the guide at: http://sourcey.com/rails-4-omniauth-using-devise-with-twitter-facebook-and-linkedin/
	def self.find_for_oauth(auth, signed_in_resource = nil)

    # Get the identity and user if they exist
    identity = Identity.find_for_oauth(auth)

    # If a signed_in_resource is provided it always overrides the existing user
    # to prevent the identity being locked with accidentally created accounts.
    # Note that this may leave zombie accounts (with no associated identity) which
    # can be cleaned up at a later date.
    user = signed_in_resource ? signed_in_resource : identity.user

    # We are dealing with a new identity that doesn't have a user yet. Else, we have this identity already stored,
		# update the user's current provider and continue.
    if user.nil?
			# Get the email address from the auth hash and find the user with that email address.
      email = auth.info.email
      user = User.where(:email => email).first if email

			logger.info auth
      # Sill no user? Create a new one to associate the identity with. Else, associate with 
			# existing user with the new identity and change the current authentication provider to the
			# provider that we are authenticating with now.
      if user.nil?
        user = User.new(
          user_name: auth.info.nickname || auth.info.name,
          email: email ? email : "#{TEMP_EMAIL_PREFIX}-#{auth.uid}-#{auth.provider}.com",
          password: Devise.friendly_token[0,20],
					provider: auth.provider
        )
        user.skip_confirmation!
      else
				user.provider = auth.provider
			end
				user.save!
    else
			user.provider = auth.provider
			user.save!
		end

    # Associate the identity with the user if needed
    if identity.user != user
      identity.user = user
      identity.save!
    end
    user
  end

  def email_verified?
    self.email && self.email !~ TEMP_EMAIL_REGEX
  end
	
	# Instead of deleting, indicate the user requested a delete & timestamp it  
  def soft_delete  
    update_attribute(:deleted_at, Time.current)  
  end  

  # Ensure user account is active  
  def active_for_authentication?  
    super && !deleted_at  
  end  

  # Provide a custom message for a deleted account   
  def inactive_message   
    !deleted_at ? super : :deleted_account  
  end  
	
	# Generate a unique identifier for the user's id property.
	private
		def generate_id
			self.id = SecureRandom.uuid
		end
	# Generate a unique username for the user based on their email address and the first 8 values of their unique identifier.
		def generate_username
			self.user_name = "#{self.email[/^[^@]*/]}#{self.id.to_s[0..7]}" if self.user_name.blank?
		end
		
		def set_default_provider
			self.provider = "default" if self.provider.blank?
		end
end
