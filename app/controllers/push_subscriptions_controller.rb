class PushSubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def create
    subscription_params = params.require(:subscription).permit(:endpoint, keys: [ :p256dh, :auth ])

    @subscription = current_user.push_subscriptions.find_or_initialize_by(
      endpoint: subscription_params[:endpoint]
    )

    @subscription.assign_attributes(
      p256dh: subscription_params[:keys][:p256dh],
      auth: subscription_params[:keys][:auth]
    )

    if @subscription.save
      render json: { success: true, message: "Subscription saved successfully" }
    else
      render json: { success: false, errors: @subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    endpoint = params[:endpoint]
    subscription = current_user.push_subscriptions.find_by(endpoint: endpoint)

    if subscription&.destroy
      render json: { success: true, message: "Subscription removed successfully" }
    else
      render json: { success: false, message: "Subscription not found" }, status: :not_found
    end
  end

  def vapid_public_key
    render json: { public_key: Rails.application.credentials.dig(:vapid, :public_key) }
  end
end
