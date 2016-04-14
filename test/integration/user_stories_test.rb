require 'test_helper'


class UserStoriesTest < ActionDispatch::IntegrationTest
  fixtures :products

  test "buying a product" do
    LineItem.delete_all
    Order.delete_all
    ruby_book = products(:ruby)

    # NAVIGATING TO THE INDEX PAGE
    get "/"
    assert_response :success
    assert_template "index"

    # ADDING PRODUCT "ruby_book" TO CART VIA AJAX
    xml_http_request :post, '/line_items', product_id: ruby_book.id
    assert_response :success # check if call was successful
    cart = Cart.find(session[:cart_id]) # pass session's cart to cart var
    assert_equal 1, cart.line_items.size # check how many items were added
    assert_equal ruby_book, cart.line_items[0].product # checking if product added was the right product

    get "/orders/new" # produces the checkout function
    assert_response :success # check if successful
    assert_template "new" # check if it's the right route

    # CHECK OUT PROCESS
    post_via_redirect "/orders",
                      order: {
                                   name: "Pierre Smith",
                                address: "123 The Street",
                                  email: "pierre@example.com",
                               pay_type: "Check"
                             }
    assert_response :success
    assert_template "index"
    cart = Cart.find(session[:cart_id])
    assert_equal 0, cart.line_items.size # checks if it successfully destroyed the cart after order is set

    # CHECK THE DATABASE FOR SUCCESSFUL ORDER CREATION
    orders = Order.all
    assert_equal 1, orders.size
    order = orders[0]

    assert_equal "Pierre Smith", order.name
    assert_equal "123 The Street", order.address
    assert_equal "pierre@example.com", order.email
    assert_equal "Check", order.pay_type

    assert_equal 1, order.line_items.size
    line_item = order.line_items[0]
    assert_equal ruby_book, line_item.product

    # CHECK IF EMAIL WORKED
    mail = ActionMailer::Base.deliveries.last
    assert_equal ["pierre@example.com"], mail.to
    assert_equal 'Pierre Smith <depot@example.com>', mail[:from].value
    assert_equal "Pragmatic Store Order Confirmation", mail.subject
  end
end
