class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.turbo_stream
    end
    Notification.create_follow_notification(@user,current_user)
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user, status: :see_other }
      format.turbo_stream
    end
    pp 'xxxxxxxxxxxxxxxxxx', @user.notifications
    redisplay_notification
  end

  def redisplay_notification
    latest_created_at = @user.notifications.maximum(:created_at)
    # pp 'xxxxxxxxxxxxxxxxxx', latest_created_at
    @user.notifications.where('created_at = ?', latest_created_at).update(read: false)
  end

end