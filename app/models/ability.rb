class Ability
  include CanCan::Ability

  def initialize(user)
  
    user ||= User.new

    if user.role? :admin
      can :manage, :all
    elsif user.role? :manager
      can :update, Store do |store|
        store.id == current_user.employee.assignment.store_id
      end
      can :manage, Shift do |shift|
        shift.assignment.store_id == current_user.employee.current_assignment.store_id
      end
      can :show, Employee do |emp|
        emp.current_assignment.store_id == current_user.employee.current_assingment.store_id
      end
      can :update, Employee do |employee|
        employee.current_assignment.store_id == current_user.employee.current_assingment.store_id
      end
      can :create, Job 
      can :read, Job
      can :update, Job
      can :read, Store
    elsif user.role? :employee
      can :update, User do |user|
        user.id == current_user.id
      end
      can :read, Employee do |employee|
        employee.id == current_user.employee_id
      end
    else
      can :read, Store
      can :create, User
    end
  
  end
end