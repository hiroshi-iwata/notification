class NotificationsController < ApplicationController
  before_action :correct_user, only: :show

  def show
    @user = User.find(params[:id])
    @notifications = Notification.where(user_id: params[:id])
  end

  def update
    @notification = Notification.find(params[:id])
    @notification.update(read: true)
    redirect_to controller: 'notifications', action: 'show', id: 'notifications.user_id'
  end

  def judge_multiple
    @user = User.find(params[:id])
    @notifications = @user.notifications.order(created_at: :desc)
  end

  private

  def notification_params
    params.require(:notification).permit(:read)
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url, status: :see_other) unless current_user?(@user)
  end
end