class WorkgroupRole < ActiveRecord::Base
  validates :name, presence: true
  has_one :workgroup_membership
end
