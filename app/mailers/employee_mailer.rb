class EmployeeMailer < ActionMailer::Base
  default from: "nphahn@gmail.com"

  def shift_msg(employee,shift)
    unless employee.user.nil?
      @shift = shift
      @employee = employee
      mail(:to => employee.user.email, :subject => "New Shift on #{shift.date}")
    end
  end

end
