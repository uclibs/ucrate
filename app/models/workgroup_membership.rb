class WorkgroupMembership < ActiveRecord::Base
  validates :user_id, :workgroup_id, :workgroup_role_id, presence: true
  belongs_to :user
  belongs_to :workgroup
  belongs_to :workgroup_role
end
