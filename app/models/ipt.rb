class Ipt < ActiveRecord::Base
  default_scope { where(stat: true) }
  has_many :programs, :foreign_key => "ipt_code", :primary_key => "code"
end
