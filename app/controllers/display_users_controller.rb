# frozen_string_literal: true

class DisplayUsersController < Hyrax::UsersController
  def index
    all_users = search(params[:uq])
    filtered_users = exclude_admins_and_non_owners(all_users)
    @users = get_current_page(filtered_users)
  end

  def search(query)
    clause = query.blank? ? nil : "%" + query.downcase.strip + "%"
    base = ::User.where(*base_query)
    if clause.present?
      base = base.where("#{Devise.authentication_keys.first} like lower(?)
                           OR display_name like lower(?)
                           OR first_name like lower(?)
                           OR last_name like lower(?)", clause, clause, clause, clause)
    end
    base.where("#{Devise.authentication_keys.first} not in (?)", [::User.batch_user_key, ::User.audit_user_key])
        .where(guest: false)
        .references(:trophies)
        .order(sort_value)
  end

  protected

    def sort_value
      sort = params[:sort].blank? ? "name" : params[:sort]
      case sort
      when 'name'
        'last_name'
      when 'name desc'
        'last_name DESC'
      end
    end

    def exclude_admins_and_non_owners(users)
      users.to_a.delete_if do |user|
        !(current_user && current_user&.admin?) && (user_work_count(user)&.zero? || user&.admin?)
      end
    end

    def get_current_page(users)
      ::User.where(id: users.map(&:id)).order(sort_value).page(params[:page]).per(10)
    end
end
