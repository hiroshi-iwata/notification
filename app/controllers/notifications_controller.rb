class NotificationsController < ApplicationController
  before_action :correct_user, only: :index

  def index
    @user = User.find(params[:user_id])
    @notifications = Notification.where(user_id: params[:user_id])
  end

  def update
    @notification = Notification.find(params[:id])
    @notification.update(read: true)
    redirect_to controller: 'notifications', action: 'index', id: 'notifications.user_id'
  end

  private

  def correct_user
    @user = User.find(params[:user_id])
    redirect_to(root_url, status: :see_other) unless current_user?(@user)
  end
end
