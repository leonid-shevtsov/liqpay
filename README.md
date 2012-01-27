# LiqPAY

This Ruby gem implements the [LiqPAY](http://liqpay.com) billing system.

As of now it only covers the [Liq&Buy 1.2 API](https://liqpay.com/?do=pages&p=cnb12), which is used to accept credit card payments on your site.

## Installation

Include the [liqpay gem](https://rubygems.org/gems/liqpay) in your app.

## Configuration

The recommended way is setting the `Liqpay.default_options` hash somewhere in
your initializers.

You MUST supply the `merchant_id` and `merchant_signature` options, that are
provided by LiqPAY when you sign up.

## Processing payments through Liq&Buy

### General flow

1. User initiates the payment process; you redirect him to LiqPAY via POST, providing necessary parameters to set up the payment's amount and description

2. Users completes payment through LiqPAY.

3. If the payment was a success: LiqPAY redirects the user to the URL you specified.

4. You validate the response against your secret signature.

5. You process the payment on your side.

6. If the payment was cancelled: LiqPAY redirects the user to the (other) URL you specified.

7. You cancel the payment on your side. 

So, LiqPAY is pretty simple, it does no server-to-server validation, just a
browser-driven flow.

### Implementation in Rails 

0. Configure Liqpay:

        # config/initializers/liqpay.rb
        Liqpay.default_options[:merchant_id] = 'MY_MERCHANT_ID'
        Liqpay.default_options[:merchant_signature] = 'MY_MERCHANT_SIGNATURE'

1. Create a `Liqpay::Request` object

    The required options are: the amount and currency of the payment, and an
    "order ID". 
    
    The "order ID" is just a random string that you will use to
    identify the payment after it has been completed. If you have an `Order`
    model (I suggest that you should), pass its ID. If not, it can be a random
    string stored in the session, or whatever, but *it must be unique*.

        @liqpay_request = Liqpay::Request.new(
          :amount => '999.99', 
          :currency => 'UAH', 
          :order_id => '123', 
          :description => 'Some Product',
          :result_url => liqpay_payment_url
        )

    **Note that this does not do anything permanent.** No saves to the database, no
    requests to LiqPAY.
    


2. Put a payment button somewhere

As you need to make a POST request, there is definitely going to be a form somewhere. 

To output a form consisting of a single "Pay with LiqPAY" button, do

        <%=liqpay_button @liqpay_request %>

Or:

        <%=liqpay_button @liqpay_request "Pay now!" %>

Or:

        <%=liqpay_button @liqpay_request do %>
          <%=link_to 'Pay now!', '#', :onclick => 'document.forms[0].submit();' %>
        <% end %>

3. Set up a receiving endpoint.
       
        # config/routes.rb
        post '/liqpay_payment' => 'payments#liqpay_payment'

        # app/controllers/payments_controller.rb
        class PaymentsController < ApplicationController
          # Skipping forgery protection here is important
          protect_from_forgery :except => :liqpay_payment

          def liqpay_payment
            @liqpay_response = Liqpay::Response.new(params)

            if @liqpay_response.success?
              # check that order_id is valid
              # check that amount matches
              # handle success
            else
              # handle error
            end
          rescue Liqpay::InvalidResponse
            # handle error
          end
        end

That's about it.

### Security considerations

* Check that amount from response matches the expected amount;
* check that the order id is valid;
* check that the order isn't completed yet (to avoid replay attacks); 

~~~

2012 Leonid Shevtsov
