class Ability
  include CanCan::Ability

  def initialize(user)
  
    user ||= User.new

    if user.role? :owner
      can :manage, :all

    elsif user.role? :manager


    elsif user.role? :employee


    end
  
  end
end
