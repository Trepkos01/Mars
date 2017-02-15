# == Schema Information
#
# Table name: issue
#
#  id                     :string         	not null, primary key
#  issue			       			:string						not null, default("")
#	 user_id								:string
#	 timestamp							:timestamp

class Issue < ActiveRecord::Base
	belongs_to :user
	validates :issue, presence: true, length: { maximum: 240 }
end