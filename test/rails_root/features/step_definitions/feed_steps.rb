def mock_authenticator_with_authentication_returning_true
  #TODO use rspec double code here. This is a very bad hack
  AdminData::Authenticator.class_eval do
    def verify(*args)
      true
    end
  end
end

def mock_authenticator_with_authentication_returning_false
  AdminData::Authenticator.class_eval do
    def verify(*args)
      false
    end
  end
end

When /^mocked feed authentication returns true$/ do
  mock_authenticator_with_authentication_returning_true
end

When /^mocked feed authentication returns false$/ do
  mock_authenticator_with_authentication_returning_false
end
