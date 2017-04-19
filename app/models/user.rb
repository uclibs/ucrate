class User < ActiveRecord::Base
  has_many :workgroup_memberships
  has_many :workgroups, through: :workgroup_memberships

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
