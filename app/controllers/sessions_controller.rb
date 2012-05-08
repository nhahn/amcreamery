class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.authenticate(params[:email], params[:password])
    tempUser = User.find_by_reset_password_code(params[:reset_code])
    if user
      session[:user_id] = user.id
      redirect_to home_path, :notice => "Logged in successfully."
    else
      flash.now[:alert] = "Invalid login or password."
      render :action => 'new'
    end
  end

  def temp_password
  end

  def forgot_password
    user = User.find_by_email(params[:email])
    if (user)
      user.reset_password_code_until = 1.hour.from_now
      user.reset_password_code = SecureRandom.hex(10)
      EmployeeMailer.reset_msg(user, user.reset_password_code).deliver
      user.save!
      redirect_to home_path, :notice => "Temporary password emailed to #{params[:email]}"
    else
      redirect_to temp_password_sessions_path, :notice => "User not found for email #{params[:email]}"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to home_path, :notice => "You have been logged out."
  end
end
