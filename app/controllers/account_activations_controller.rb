class AccountActivationsController < ApplicationController

    def edit
      user = User.find_by(email: params[:email])
      if user && !user.activated? && user.authenticated?(:activation, params[:id])
        user.activate
        user.update_attribute(:activated,    true)
        user.update_attribute(:activated_at, Time.zone.now)
        log_in user
        flash[:success] = "Account activated!"
        redirect_to user
        signup_notification
      else
        flash[:danger] = "Invalid activation link"
        redirect_to root_url
      end
    end

    def signup_notification
      notification = current_user.notifications.new(
        message: "初回ログインありがとうございます！",
        action: "signup"
      )
      if notification.save
        flash[:notice] = notification.message
      else
        puts "通知の作成に失敗しました。"
      end
    end
  end
