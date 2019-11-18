class GamioController < ApplicationController
  skip_before_action :verify_authenticity_token
  def create_account
    if params[:token] != ENV['GAMIO_TOKEN'] || params[:token].blank?
      result = { result: 'token_error' }.to_json
      return render json: result
    end
    user = User.create!(
      email: params[:email],
      password: params[:password],
      agreement: true, approved: true,
      admin: false,
      moderator: false,
      confirmed_at: Time.now.utc
    )
    if user.errors.present?
      result = { result: 'db_error', message: user.errors.messages.map { |k, e| e }.join(',') }.to_json
      return render json: result
    end
    result = { result: 'ok' }.to_json
    render json: result
  end
end
