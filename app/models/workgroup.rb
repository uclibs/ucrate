class Workgroup < ActiveRecord::Base
	validates :title, :description, presence: true
	
end
