
# frozen_string_literal: true
class UsersReport < Report
  def self.report_objects
    User.all
  end

  def self.fields(user = User.new)
    [
      { id: user.id },
      { email: user.email },
      { name: user.name },
      { first_name: user.first_name },
      { last_name: user.last_name }
    ]
  end
end
