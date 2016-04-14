class StoreController < ApplicationController
  skip_before_action :authorize
  # include CurrentStoreCounter
  # before_action :set_store_counter, only: [:index]
  include CurrentCart
  before_action :set_cart, only: [:index]

  def index
    @products = Product.order(:title)

    # session[:counter] += 1

    # without using a module
    if session[:counter].nil?
      counter = 1
      session[:counter] = counter
    else
      session[:counter] += 1
    end
  end
end
