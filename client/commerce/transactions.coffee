FlowRouter.route '/transactions',
    action: ->
        BlazeLayout.render 'layout',
            main: 'transactions'


if Meteor.isClient
    Template.transactions.onCreated ->
        @autorun -> Meteor.subscribe 'type', 'transaction'
        @autorun -> Meteor.subscribe 'type', 'service_request'
    Template.transactions.helpers
        service_request_docs: -> Docs.find type:'service_request'

            
    Template.transactions.events
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

        # 'click .purchase_item': ->
        #     Session.set 'purchasing_item', @parent_id
        #     Session.set 'current_transactions_item', @_id
        #     parent_doc = Docs.findOne @parent_id
        #     if parent_doc.dollar_price > 0
        #         Template.instance().checkout.open
        #             name: 'Tori Webster Inspires, LLC'
        #             description: parent_doc.title
        #             amount: parent_doc.dollar_price*100
        #     else
        #         Meteor.call 'register_transaction', @parent_id, (err,response)=>
        #             if err then console.error err
        #             else
        #                 Bert.alert "You have purchased #{parent_doc.title}.", 'success'
        #                 Docs.remove @_id
        #                 FlowRouter.go "/transactions"
                        
                    


if Meteor.isServer
    Meteor.methods
        'add_to_transactions': (doc_id)->
            Docs.insert
                type: 'transactions_item'
                parent_id: doc_id
                number: 1
        
        'remove_from_transactions': (doc_id)->
            Docs.remove
                type: 'transactions_item'
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
        
        
    publishComposite 'transactions', ->
        {
            find: ->
                Docs.find
                    type: 'transactions_item'
                    author_id: @userId            
            children: [
                { find: (transactions_item) ->
                    Docs.find transactions_item.parent_id
                    }
                ]    
        }