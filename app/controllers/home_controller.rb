# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @profiles = Profile.all
    render json: @profiles
  end
end
