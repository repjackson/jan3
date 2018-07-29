FlowRouter.route '/cart',
    action: ->
        BlazeLayout.render 'layout',
            main: 'cart'

FlowRouter.route '/cart-profile/:user_id',
    action: ->
        BlazeLayout.render 'layout',
            main: 'cart_profile'


if Meteor.isClient
    Template.cart.onCreated ->
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

    Template.cart_checkout.helpers 
        cart_items: ->
            Docs.find
                type: 'cart_item'
                author_id: Meteor.userId()
                
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
                        
                    


if Meteor.isServer
    Meteor.methods
        'add_to_cart': (doc_id)->
            Docs.insert
                type: 'cart_item'
                parent_id: doc_id
                number: 1
        
        'remove_from_cart': (doc_id)->
            Docs.remove
                type: 'cart_item'
                parent_id: doc_id
        
        'register_transaction': (product_id)->
            product = Docs.findOne product_id
            if product.point_price
                console.log 'product point price', product.point_price
                console.log 'purchaser amount before', Meteor.user().points
                Meteor.users.update Meteor.userId(),
                    $inc: points: -product.point_price
                console.log 'purchaser amount after', Meteor.user().points
                
                console.log 'seller amount before', Meteor.users.findOne(product.author_id).points
                Meteor.users.update product.author_id,
                    $inc: points: product.point_price
                console.log 'seller amount after', Meteor.users.findOne(product.author_id).points
            Docs.insert
                type: 'transaction'
                parent_id: product_id
                sale_dollar_price: product.dollar_price
                sale_point_price: product.point_price
                author_id: Meteor.userId()
                recipient_id: product.author_id
        
        
    publishComposite 'cart', ->
        {
            find: ->
                Docs.find
                    type: 'cart_item'
                    author_id: @userId            
            children: [
                { find: (cart_item) ->
                    Docs.find cart_item.parent_id
                    }
                ]    
        }