class Doorkeeper::ApplicationPolicy < ApplicationPolicy

  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.is_of_role? :admin
        scope.order_by(:name.asc)
      else
        scope.where(owner_id: user.id, owner_type: 'User')
              .order_by(:name.asc)
      end
    end
  end

  def index?
    user.is_of_role?(:admin) ? true : user.developer?
  end

  def show?
    user.is_of_role?(:admin) ? true : (record.owner == user)
  end

  def create?
    index?
  end

  def destroy?
    show?
  end

  def update?
    show?
  end

end
