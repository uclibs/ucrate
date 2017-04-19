class WorkgroupMembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_workgroup_membership, only: [:edit, :update, :destroy]

  def initialize
    if WorkgroupRole.count == 0
      WorkgroupRole.create({id: 1, name: 'owner'})
      WorkgroupRole.create({id: 2, name: 'editor'})
      WorkgroupRole.create({id: 3, name: 'reader'})
    end
  end

  def new
    @workgroup_membership = WorkgroupMembership.new
  end

  def edit
  end

  def create
    @workgroup_membership = WorkgroupMembership.new(workgroup_membership_params)
    if @workgroup_membership.save
      redirect_to workgroup_path(id: params[:workgroup_membership][:workgroup_id]), notice: "#{ User.find(params[:workgroup_membership][:user_id]).email } was successfully added."
    else
      redirect_to workgroups_path, notice: "There was a problem creating the workgroup membership."
    end
  end

  def update
    if @workgroup_membership.update_attributes(workgroup_membership_params)
      redirect_to workgroup_path(id: params[:workgroup_membership][:workgroup_id]), notice: "#{ User.find(params[:workgroup_membership][:user_id]).email }'s role has been updated."
    else
      redirect_to workgroups_path, notice: "There was a problem editing the workgroup member's role."
    end
  end

  def destroy
    @workgroup_membership.destroy
    redirect_to workgroup_path(id: params[:workgroup_id])
  end

  private

  def set_workgroup_membership
    @workgroup_membership = WorkgroupMembership.find(params[:id])
  end

  def workgroup_membership_params
    params.require(:workgroup_membership).permit(:user_id, :workgroup_id, :workgroup_role_id)
  end

end
