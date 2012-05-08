class EmployeeMailer < ActionMailer::Base
  default from: "nphahn@gmail.com"

  def shift_msg(employee,shift)
    unless employee.user.nil?
      @shift = shift
      @employee = employee
      mail(:to => employee.user.email, :subject => "New Shift on #{shift.date.strftime("%B, %d %Y")}")
    end
  end

  def login_msg(user, password)
    unless user.nil?
      @employee = user.employee
      @password = password
      mail(:to => user.email, :subject => "A New Account has been Generated for You")
    end
  end

  def reset_msg(user, password)
    unless user.nil?
      @employee = user.employee
      @password = password
      logger.info user.email
      mail(:to => user.email, :subject => "You temporary password for A&M Creamery")
    end
  end

end
