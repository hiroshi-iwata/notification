class Notification < ApplicationRecord
  INTERVAL = 5.minutes.ago
  scope :recent, -> { where("created_at >= ?", INTERVAL)}
  scope :recent_follow, -> {
    where(
      created_at: INTERVAL..Time.current,
      action: ['follow', 'summarize_follow']
    )
  }
  scope :only_recent_follow, -> {
    where(
      created_at: INTERVAL..Time.current,
      action: 'follow'
    )
  }
  default_scope -> { order(created_at: :desc) }
  belongs_to :relationship, optional: true
  belongs_to :user
  enum status: [:else, :initial_notification]

  def self.create_follow_notification(followed_user, follower_user)
    @notification = followed_user.notifications.new(
        message: follower_user.name.to_s + "さんにフォローされました。",
        action: "follow",
        relationship_id: Relationship.find_by(followed_id: followed_user.id, follower_id: follower_user.id).id,
        status: :else
      )
    if @notification.save
      if notification_first?(followed_user) || within_allowed_time?(followed_user)
        oldest_within_period = followed_user.notifications.only_recent_follow.last
        oldest_within_period.status = :initial_notification
        oldest_within_period.save
      else
        puts "through"
        create_summarize_follow(followed_user, follower_user)
      end
    else
      puts "通知の作成に失敗しました。"
      raise "通知の作成に失敗しました。"
    end
  end

  def self.notification_first?(user)
    recent_notifications_count = user.notifications.recent_follow.count
    recent_notifications_count == 1
  end

  def self.within_allowed_time?(user)
    first_recent_notification = user.notifications.where(status: :initial_notification).first
    if first_recent_notification
      if first_recent_notification.created_at <= INTERVAL
        return true
      else
        return false
      end
    else
      return false
    end
  end

  def self.create_summarize_follow(followed_user,follower_user)
    recent_notifications_count = Notification.where("created_at >= ? AND user_id = ? AND action = ?", INTERVAL, followed_user.id, "follow").count
    if recent_notifications_count >= 2
      display_notification_count = recent_notifications_count - 1
      @notification = followed_user.notifications.new(
        message: follower_user.name.to_s + "さん他" + display_notification_count.to_s + "名にフォローされました。",
        action: "summarize_follow",
        relationship_id: Relationship.find_by(followed_id: followed_user.id, follower_id: follower_user.id).id,
        status: :else
      )
      if @notification.save
        mark_as_read(followed_user)
      else
        puts "通知の作成に失敗しました。"
        raise "通知の作成に失敗しました。"
      end
    else
    end
  end

  def self.mark_as_read(user)
    latest_created_at = user.notifications.maximum(:created_at)
    user.notifications.where('created_at >= ? AND created_at < ? AND action IN (?)', INTERVAL, latest_created_at, ['follow', 'summarize_follow']).update(read: true)
  end

  def follow_action_notification?(notification)
    notification.action == "follow" || notification.action == "summarize_follow"
  end

  def latest_notification?(user)
    latest_notification = user.notifications.order(created_at: :desc).first
    user.notifications.first == latest_notification&.id
  end

  def is_read?
    !read
  end

  def time_ago(notification)
    seconds_ago = (Time.now - notification.created_at).to_i
    case seconds_ago
    when 0...60
      "#{seconds_ago}秒前"
    when 60...3600
      "#{seconds_ago / 60}分前"
    when 3600...86400
      "#{seconds_ago / 3600}時間前"
    else
      "#{seconds_ago / 86400}日前"
    end
  end
end
