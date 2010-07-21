class String
  unless method_defined?(:html_safe)
    def html_safe
      self
    end
  end
end