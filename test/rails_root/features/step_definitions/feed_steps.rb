AdminData::Authenticator.extend(
  Module.new{
    def verify(controller)
      #TODO use rspec double code here. This is a very bad hack
      true
    end
  }
)
