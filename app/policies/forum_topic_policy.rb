# frozen_string_literal: true

class ForumTopicPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.level >= record.min_level_id
  end

  def update?
    unbanned? && show? && (user.is_moderator? || (record.creator_id == user.id && !record.is_locked?))
  end

  def destroy?
    unbanned? && show? && user.is_moderator?
  end

  def undelete?
    unbanned? && show? && user.is_moderator?
  end

  def mark_all_as_read?
    !user.is_anonymous?
  end

  def reply?
    show? && (user.is_moderator? || !record.is_locked?)
  end

  def moderate?
    user.is_moderator?
  end

  def rate_limit_for_create(**_options)
    { rate: 1.0 / 2.minutes, burst: 3 }
  end

  def permitted_attributes
    [
      :title, :category, :category_id, { original_post_attributes: [:id, :body] },
      ([:is_sticky, :is_locked, :min_level] if moderate?),
    ].compact.flatten
  end

  def html_data_attributes
    super + [:is_read?]
  end
end
