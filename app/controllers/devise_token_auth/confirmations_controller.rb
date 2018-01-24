module DeviseTokenAuth
  class ConfirmationsController < DeviseTokenAuth::ApplicationController
    before_action :set_user_by_token, only: [:create]

    def show
      @resource = resource_class.confirm_by_token(params[:confirmation_token])

      if @resource && @resource.id && @resource.errors.empty?
        expiry = nil
        if defined?(@resource.sign_in_count) && @resource.sign_in_count > 0
          expiry = (Time.now + 1.second).to_i
        end

        client_id, token = @resource.create_token expiry: expiry

        @resource.save!
        sign_in(@resource)

        yield @resource if block_given?

        render json: {
          data: resource_data(resource_json: @resource.token_validation_response)
        }
      else
        raise ActionController::RoutingError, 'Not Found'
      end
    end

    def create
      return render_error_unauthorized unless @resource

      # make sure account doesn't use oauth2 provider
      return render_error_unauthorized unless @resource.provider == 'email'

      @resource.send_confirmation_instructions

      render json: { data: {} }
    end

    def render_error_unauthorized
      render_error(401, 'Unauthorized')
    end
  end
end
