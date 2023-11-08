class Notification < ApplicationRecord
  # 直接書かず変数に渡しているのとても良いです。ただ定数で書きましょう。グローバル変数は危険なので使われないです。
  $interval = Time.now - 5.minutes
  scope :recent, -> { where("created_at >= ?", $interval)}
  scope :recent_follow, -> (three_minutes_ago, user) {
  where("created_at >= ? AND user_id = ? AND (action = 'follow' OR action = 'summarize_follow')", three_minutes_ago, user.id)
}
  # インデントを合わせる
  # 読みやすさ等のため、SQLべた書きは避けることが多い
  # three_minutes_agoという、3分という決め打ちの名前は控える
  scope :recent_follow, -> (three_minutes_ago, user) {
    where(created_at: three_minutes_ago..Time.current, user_id: user.id, action: ['follow', 'summarize_follow'])
  }
  scope :only_recent_follow, -> (three_minutes_ago, user) {
  where("created_at >= ? AND user_id = ? AND action = ?", three_minutes_ago, user.id, "follow")
}
  scope :individual_notification, -> (user){ where("user_id = ?", user.id)}
  default_scope -> { order(created_at: :desc) }
  belongs_to :relationship, optional: true
  belongs_to :user
  enum status: [:starting]

  def notification_first?(user)
    recent_notifications_count = user.notifications.recent_follow($interval, user).count
    # userはscopeで渡すのでこれでいけませんか？もしくはscopeにuserを渡す必要があるか検討しても良いかもです
    recent_notifications_count = self.recent_follow($interval, user).count
    recent_notifications_count == 1
  end

  # judgeもthresholdも具体的でなく何をしているか伝わりづらいので、初見で見ても何をしているかわかる名前を心がけましょう
  def judge_threshold(user)
    # ここのwhereもActive Recordのクエリメソッドを使いましょう
    threshold_notification = user.notifications.where("status = ?",0).first
    # ややこしい分岐はバグの温床になるので、unlessでなくif文にできる時はそうしましょう
    unless threshold_notification.nil?
      if threshold_notification.created_at <= $interval
        # statusって何を管理してましたっけ？見る感じnilと0が入るようですが、その場合0と1とかで管理すべきかと！
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
    user.notifications.where('created_at >= ? AND created_at < ?', $interval, latest_created_at).update(read: true)
    oldest_within_five_minutes = user.notifications.only_recent_follow($interval, user).last
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

  # これはインスタンスメソッドなので、引数に自インスタンスを渡す必要はないです。このメソッド内のnotificationは書かなくて良いか、selfでも動くはずです
  def hidden_notification?(notification)
    # notification.read == true は notification.read と結果は同じですよね？
    if notification.action == "hidden_follow" || notification.read == true
      # メソッドの意味的にこっちがtrueで
      return false
    else
      # こっちがfalseじゃないでしょうか？
      return true
    end
  end

  # この表示親切ですね。elseifが多くなる場合、case文を検討するのも良いと思います！
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
