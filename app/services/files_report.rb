# frozen_string_literal: true
class FilesReport < Report
  def self.report_objects
    FileSet.all
  end

  def self.fields(file = FileSet.new)
    [
      { id: file.id },
      { title: file.title[0] },
      { filename: file.label },
      { owner: file.creator },
      { depositor: file.depositor },
      { edit_users: file.edit_users.join(" ") }
    ]
  end
end
