FlowRouter.route '/cart',
    action: ->
        BlazeLayout.render 'layout',
            main: 'cart'

FlowRouter.route '/cart-profile/:user_id',
    action: ->
        BlazeLayout.render 'layout',
            main: 'cart_profile'


Template.cart.onCreated ->
    @autorun => Meteor.subscribe 'type','cart_item'
Template.cart_widget.onCreated ->
    @autorun => Meteor.subscribe 'type','cart_item'
    # if Meteor.isDevelopment
    #     stripe_key = Meteor.settings.public.stripe.testPublishableKey
    #     # console.log 'using test key'
    # else if Meteor.isProduction
    #   stripe_key = Meteor.settings.public.stripe.livePublishableKey
    # else 
    #     console.log 'not dev or prod'
    
    # @autorun -> Meteor.subscribe 'cart'
    # Template.instance().checkout = StripeCheckout.configure(
    #     key: stripe_key
    #     image: '/toriwebster-logomark-04.png'
    #     locale: 'auto'
    #     # zipCode: true
    #     token: (token) ->
    #         # console.log token
    #         purchasing_item = Docs.findOne Session.get 'purchasing_item'
    #         console.dir 'purchasing_item', purchasing_item
    #         charge = 
    #             amount: purchasing_item.price*100
    #             currency: 'usd'
    #             source: token.id
    #             description: token.description
    #             receipt_email: token.email
    #         Meteor.call 'processPayment', charge, (error, response) =>
    #             if error then Bert.alert error.reason, 'danger'
    #             else
    #                 Meteor.call 'register_transaction', purchasing_item._id, (err, response)->
    #                     if err then console.error err
    #                     else
    #                         Bert.alert "You have purchased #{purchasing_item.title}.", 'success'
    #                         Docs.remove Session.get('current_cart_item')
    #                         FlowRouter.go "/account"
    #     # closed: ->
    #     #     Bert.alert "Payment Canceled", 'info', 'growl-top-right'
    # )

Template.cart_widget.helpers 
    cart_docs: ->
        Docs.find
            type: 'cart_item'
            # author_id: Meteor.userId()
            
            
Template.cart.helpers 
    cart_items: ->
        Docs.find
            type: 'cart_item'
            # author_id: Meteor.userId()
            
    total_items: -> Docs.find({type: 'cart_item'},{author_id: Meteor.userId()}).count()
        
    subtotal: ->    
        subtotal = 0
        cart_items = Docs.find({type: 'product'}).fetch()
        for cart_item in cart_items
            subtotal += cart_item.price
        subtotal
        
    can_purchase: ->
        console.log @parent().point_price
        console.log Meteor.user().points
            
        if @parent().point_price
            if Meteor.user().points > @parent().point_price 
                console.log true
                return true
            else
                console.log false
                return false
        else 
            return true
        
        
Template.cart.events
    # 'click .buy_course': ->
    #     if @price > 0
    #         Template.instance().checkout.open
    #             name: @title
    #             description: @subtitle
    #             amount: @price*100
    #     else
    #         Meteor.call 'enroll', @_id, (err,res)=>
    #             if err then console.error err
    #             else
    #                 Bert.alert "You are now enrolled in #{@title}", 'success'
    #                 # FlowRouter.go "/course/#{_id}"

    'click .purchase_item': ->
        Session.set 'purchasing_item', @parent_id
        Session.set 'current_cart_item', @_id
        parent_doc = Docs.findOne @parent_id
        if parent_doc.dollar_price > 0
            Template.instance().checkout.open
                name: 'Tori Webster Inspires, LLC'
                description: parent_doc.title
                amount: parent_doc.dollar_price*100
        else
            Meteor.call 'register_transaction', @parent_id, (err,response)=>
                if err then console.error err
                else
                    Bert.alert "You have purchased #{parent_doc.title}.", 'success'
                    Docs.remove @_id
                    FlowRouter.go "/transactions"
                    
                
Template.add_to_cart_button.events
    'click .add_to_cart': ->
        Meteor.call 'add_to_cart', @_id, (err,res)=>
            if err
                Bert.alert "Error adding #{@title} to cart: #{err.reason}", 'danger', 'growl-top-right'
            else
                Bert.alert "#{@title} added to cart.", 'success', 'growl-top-right'


Template.remove_from_cart_button.events
    'click .remove_cart_item': ->
        if confirm 'Remove cart item?'
            Meteor.call 'remove_from_cart', @_id, (err,res)=>
            if err
                Bert.alert "Error removing #{@title} from cart: #{err.reason}", 'info', 'growl-top-right'
            else
                Bert.alert "#{@title} removed from cart.", 'info', 'growl-top-right'