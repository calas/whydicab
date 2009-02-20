module Merb
  module ArticlesHelper
    def new_or_edit
      @article.new_record? ? 'New' : 'Edit'
    end
  end
end # Merb
