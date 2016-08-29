class Workgroup < ActiveRecord::Base
	validates :title, :description, presence: true
  has_many :workgroup_memberships
  has_many :users, through: :workgroup_memberships
end
