module DeviseTokenAuth
  class ConfirmationsController < DeviseTokenAuth::ApplicationController
    def show
      @resource = resource_class.confirm_by_token(params[:confirmation_token])

      if @resource && @resource.id
        expiry = nil
        if defined?(@resource.sign_in_count) && @resource.sign_in_count > 0
          expiry = (Time.now + 1.second).to_i
        end

        client_id, token = @resource.create_token expiry: expiry

        sign_in(@resource)
        @resource.save!

        yield @resource if block_given?

        render json: {
          data: {}
        }
      else
        raise ActionController::RoutingError.new('Not Found')
      end
    end
  end
end
