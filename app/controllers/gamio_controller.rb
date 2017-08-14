class GamioController < ApplicationController
  skip_before_filter :verify_authenticity_token
  def create_account
    req = JSON.parse(request.body.read)
    if req['token'] != ENV['GAMIO_TOKEN'] || req['token'].blank?
      result = { result: 'token_error' }.json
      return render json: result
    end
    user = User.new.tap(&:build_account)
    user.account.username = req['username']
    user.email = req['email']
    user.password = req['password']
    user.password_confirmation = req['password']
    user.confirmed_at = Time.now
    user.save
    if user.errors.present?
      result = { result: 'db_error', message: user.errors.messages.join(',') }.json
      return render json: result
    end
    result = { result: 'ok' }.json
    render json: result
  end
end
