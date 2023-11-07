class Relationship < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  has_many :notifications, dependent: :destroy
  validates :follower_id, presence: true
  validates :followed_id, presence: true

  def self.follow_notification(user,current_user)
    @notification = user.notifications.new(
        message: current_user.name.to_s + "さんにフォローされました。",
        action: "follow",
        relationship_id: Relationship.find_by(followed_id: user.id, follower_id: current_user.id).id
      )
    if @notification.save
      if @notification.notification_first?(user) || @notification.judge_threshold(user)
      else
        puts "through"
        create_summarize_follow(user,current_user)
      end
    else
      puts "通知の作成に失敗しました。"
    end
  end

  def self.create_summarize_follow(user,current_user)
    recent_notifications_count = Notification.where("created_at >= ? AND user_id = ? AND action = ?", 3.minutes.ago, user.id, "follow").count
    if recent_notifications_count >= 2
      display_notification_count = recent_notifications_count - 1
      @notification = user.notifications.new(
        message: current_user.name.to_s + "さん他" + display_notification_count.to_s + "名にフォローされました。",
        action: "summarize_follow",
        relationship_id: Relationship.find_by(followed_id: user.id, follower_id: current_user.id).id
      )
      if @notification.save
        @notification.change_hidden(user)
      else
        puts "通知の作成に失敗しました。"
      end
    else
    end
  end

end
