# LiqPAY

This Ruby gem implements the [LiqPAY](https://www.liqpay.com) billing system API, as described in [the LiqPAY documentation](https://www.liqpay.com/doc).

**Users of version 0.1.2 and earlier:** your version of the gem uses the older, deprecated LiqPAY API; you should migrate to >v1, but it requires you to change configuration and set up a server callback endpoint, so it's not a trivial upgrade.

## Demo

There is a demo app at http://liqpay-demo.herokuapp.com, source at https://github.com/leonid-shevtsov/liqpay_demo

## Installation

Include the [liqpay gem](https://rubygems.org/gems/liqpay) in your `Gemfile`:

```ruby
gem 'liqpay', '~>1.0.0'
```

The gem requries at least Ruby 1.9.

## Configuration

You can provide all of the payment options in the request object, but the recommended way is setting the `Liqpay.default_options` hash somewhere in
your initializers.

You should supply the `public_key` and `private_key` options, that are
provided by LiqPAY when you sign up and create a shop on the [shops page](https://www.liqpay.com/admin/business):

```ruby
# config/initializers/liqpay.rb
Liqpay.default_options = {
    public_key: ENV['LIQPAY_PUBLIC_KEY'],
    private_key: ENV['LIQPAY_PRIVATE_KEY'],
    currency: 'UAH'
}
```


## Processing payments through LiqPay

### General flow

1. User initiates the payment process; you redirect him to LiqPAY via a POST form, providing necessary parameters such as the payment's amount, order id and description.

2. Users completes payment through LiqPAY.

3. LiqPAY redirects the user to the URL you specified with GET.

4. You wait for a callback that LiqPAY will POST to your designated `server_url`.

5. If the payment was successful: You process the payment on your side.

6. If the payment was cancelled: You cancel the operation.

The most recent version of the LiqPAY API *requires* you to have a serverside endpoint, which makes it impossible to test it with a local address.

### Implementation in Rails

0. Configure Liqpay

1. Create a `Liqpay::Request` object

    The required options are: the amount and currency of the payment, and an
    "order ID".

    The "order ID" is just a random string that you will use to
    identify the payment after it has been completed. If you have an `Order`
    model (I suggest that you should), pass its ID. If not, it can be a random
    string stored in the session, or whatever, but *it must be unique*.

    ```ruby
    @liqpay_request = Liqpay::Request.new(
      amount: '999.99',
      currency: 'UAH',
      order_id: '123',
      description: 'Some Product',
      result_url: order_url(@order),
      server_url: liqpay_payment_url
    )
    ```

    **Note that this does not do anything permanent.** No saves to the database, no
    requests to LiqPAY.

2. Put a payment button somewhere

    As you need to make a POST request, there is definitely going to be a form somewhere.

    To output a form consisting of a single "Pay with LiqPAY" button, do

    ```erb
    <%=liqpay_button @liqpay_request %>
    ```

    Or:

    ```erb
    <%=liqpay_button @liqpay_request, title: "Pay now!" %>
    ```

    Or:

    ```erb
    <%=liqpay_button @liqpay_request do %>
      <%=link_to 'Pay now!', '#', onclick: 'document.forms[0].submit();' %>
    <% end %>
    ```

3. Set up a receiving endpoint.

    ```ruby
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
    ```

That's about it.

### Security considerations

* Check that amount from response matches the expected amount;
* check that the order id is valid;
* check that the order isn't completed yet (to avoid replay attacks);

- - -

Ruby implementation (c) 2012-2014 Leonid Shevtsov
