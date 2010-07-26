class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # Guest user
    if user.role? :admin
      can :manage, :all
    elsif user.role? :reporter
      can :manage, Project
      can :manage, FundingFlow
      can :manage, Organization
      can :manage, Activity
      can :manage, OtherCost
      can :manage, Comment
      can :manage, CodeAssignment
      can :read, Code
    end
  end
end
