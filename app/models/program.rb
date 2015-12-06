class Program < ActiveRecord::Base
  default_scope { order(faculty_code: :asc, iptcode: :asc) }
  default_scope { where(programstat_code: 'A') }

  belongs_to :ipt

end
