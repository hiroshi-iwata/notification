class Notification < ApplicationRecord
  INTERVAL = 5.minutes.ago
  scope :recent, -> { where("created_at >= ?", INTERVAL)}
  scope :recent_follow, -> (notification_interval, user) {
  where("created_at >= ? AND user_id = ? AND (action = 'follow' OR action = 'summarize_follow')", notification_interval, user.id)
}
  scope :only_recent_follow, -> (notification_interval, user) {
  where("created_at >= ? AND user_id = ? AND action = ?", notification_interval, user.id, "follow")
}
  scope :individual_notification, -> (user){ where("user_id = ?", user.id)}
  default_scope -> { order(created_at: :desc) }
  belongs_to :relationship, optional: true
  belongs_to :user
  enum status: [:starting]

  def notification_first?(user)
    recent_notifications_count = user.notifications.recent_follow(INTERVAL, user).count
    recent_notifications_count == 1
  end

  def judge_threshold(user)
    threshold_notification = user.notifications.where("status = ?",0).first
    unless threshold_notification.nil?
      if threshold_notification.created_at <= INTERVAL
        threshold_notification.status = nil
        threshold_notification.save
        return true
      else
        return false
      end
    else
      return false
    end
  end

  def change_hidden(user)
    latest_created_at = user.notifications.maximum(:created_at)
    user.notifications.where('created_at >= ? AND created_at < ?', INTERVAL, latest_created_at).update(read: true)
    oldest_within_five_minutes = user.notifications.only_recent_follow(INTERVAL, user).last
    oldest_within_five_minutes.status = 0
    oldest_within_five_minutes.save
  end

  def five_minutes_ago?(user)
    recent_notifications = user.notifications.recent
    return recent_notifications
  end

  def follow_action_notification?(notification)
    notification.action == "follow" || notification.action == "summarize_follow"
  end

  def latest_notification?(user)
    latest_notification = user.notifications.order(created_at: :desc).first
    user.notifications.first == latest_notification&.id
  end

  def test(notification)
    notification.recent_follow.count
  end

  def hidden_notification?(notification)
    if notification.action == "hidden_follow" || notification.read == true
      return false
    else
      return true
    end
  end

  def time_ago(notification)
    seconds_ago = (Time.now - notification.created_at).to_i
    if seconds_ago < 60
      "#{seconds_ago}秒前"
    elsif seconds_ago < 3600
      "#{seconds_ago / 60}分前"
    elsif seconds_ago < 86400
      "#{seconds_ago / 3600}時間前"
    else
      "#{seconds_ago / 86400}日前"
    end
  end

end
