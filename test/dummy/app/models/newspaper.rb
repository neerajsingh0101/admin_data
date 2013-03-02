class Newspaper < ActiveRecord::Base
  self.table_name   = :papers
  self.primary_key  =  :paper_id
end
