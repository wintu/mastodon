class GamioController < ApplicationController
  skip_before_action :verify_authenticity_token
  def create_account
    if params[:token] != ENV['GAMIO_TOKEN'] || params[:token].blank?
      result = { result: 'token_error' }.to_json
      return render json: result
    end
    user = User.new.tap(&:build_account)
    user.account.username = params[:username]
    user.email = params[:email]
    user.password = params[:password]
    user.password_confirmation = params[:password]
    user.confirmed_at = Time.now
    user.save
    if user.errors.present?
      result = { result: 'db_error', message: user.errors.messages.map { |k, e| e }.join(',') }.to_json
      return render json: result
    end
    result = { result: 'ok' }.to_json
    render json: result
  end
end
