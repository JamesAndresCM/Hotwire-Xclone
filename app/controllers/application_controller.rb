class ApplicationController < ActionController::Base
  include Pagy::Backend
  include DeviseWhitelist
  before_action :authenticate_user!
end
