class ApplicationController < ActionController::Base
  include Pagy::Backend
  include DeviseWhitelist
  before_action :authenticate_user!
  before_action :set_current_user, if: :user_signed_in?

  private

  def set_current_user = Current.user = current_user
end
