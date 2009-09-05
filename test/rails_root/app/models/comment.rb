class Comment < ActiveRecord::Base
  
  belongs_to :article
  
  before_save :set_body_html

  private

  def set_body_html
    self.body_html = self.body
  end

end
