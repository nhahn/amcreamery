class Ability
  include CanCan::Ability

  def initialize(user)
  
    user ||= User.new

    if user.role? :admin
      can :manage, :all
    elsif user.role? :manager
      store = user.employee.current_assignment.store_id
      can :read, Store
      can :update, Store, :id => store
      can :manage, Shift, { :assignment => { :store_id => store } } 
      can :show, Employee do |emp|
        emp.current_assignment.store_id == user.employee.current_assignment.store_id
      end
      can :update, Employee do |employee|
        employee.current_assignment.store_id == user.employee.current_assignment.store_id
      end
      can :create, Job 
      can :read, Job
      can :update, Job
      can :read, Store
    elsif user.role? :employee
      can :update, User, :id => user.id
      can :read, Employee, :id => user.employee_id
      can :read, Shift, { :assignment => {:employee_id => user.employee_id}}
      can :read, Store
    else
      can :read, Store
      can :create, User
    end
  
  end
end
