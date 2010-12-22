# HttpBasic authenticator for feed authentication
module AdminData
  class Authenticator

    def initialize(userid, password)
      @userid = userid
      @password = password
    end

    def verify(controller)
      controller.authenticate_or_request_with_http_basic { |_userid, _password| (_userid == @userid) && (_password == @password) }
    end

  end
end
