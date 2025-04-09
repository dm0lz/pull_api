module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :session_id

    def connect
      set_session_id || reject_unauthorized_connection
    end

    private
      def set_session_id
        if session = Session.find_by(id: cookies.signed[:session_id])
          self.session_id = session.user.id
        else
          self.session_id = cookies.encrypted["_pull_api_session"]["session_id"] rescue nil
        end
      end
  end
end
