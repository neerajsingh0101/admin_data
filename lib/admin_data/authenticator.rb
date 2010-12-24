# HttpBasic authenticator for feed authentication
module AdminData
  class Authenticator

    def initialize(userid, password)
      @userid = userid
      @password = password
    end

    def verify(controller)
      controller.authenticate_or_request_with_http_basic { |_u, _p| (_u == @userid) && (_p == @password) }
    end

  end
end
