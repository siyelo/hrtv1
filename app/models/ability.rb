class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new(:roles => []) #guest
    if user.admin?
      can :manage, :all
    elsif user.activity_manager?
      can :manage, Activity
      can :approve, Activity
      can :manage, [Project, FundingFlow, Organization,
        Activity, OtherCost, Comment, CodeAssignment]
      can :create, Organization
      can :update, User, :id => user.id
      can :read, Code
      can :read, ModelHelp
      can :read, FieldHelp
    elsif user.reporter?
      can :manage, [Project, FundingFlow, Organization,
        Activity, OtherCost, Comment, CodeAssignment]
      # :manage seems to let all non-RESTful actions thru,
      # so explicity remove this perm for reporters
      cannot :approve, Activity
      can :create, Organization
      can :update, User, :id => user.id
      can :read, Code
      can :read, ModelHelp
      can :read, FieldHelp
      can :manage, HelpRequest
      can :read, :users_in_my_organization
    else #guest user
    end
  end
end
