module CurrentStoreCounter
  extend ActiveSupport::Concern

  private

    def set_store_counter # gets cart by id or creates a car in session if cart is MIA
      counter = session[:counter]
    rescue ActiveRecord::RecordNotFound
      counter = 0
      session[:counter] = counter
    end
end
