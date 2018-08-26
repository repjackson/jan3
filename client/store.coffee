FlowRouter.route '/store', 
    name:'store'
    action: -> BlazeLayout.render 'layout', main: 'store'

Template.store.onCreated ->
    @autorun => Meteor.subscribe 'type', 'product'

Template.store.helpers
    products: -> Docs.find type:'product'

Template.store.events
    'keydown #new_product': (e,t)->
        if e.which is 13
            new_product = $('#new_product').val().trim()
            if new_product.length > 0
                Docs.insert 
                    text: new_product
                    type:'product'
                $('#new_product').val('')

Template.product_card.events
    'click .delete_comment': ->
        if confirm 'Delete comment?'
            Docs.remove @_id

# Template.add_to_cart_button.events
#     'click .add_to_cart': ->
#         current_customer_jpid = Meteor.user().customer_jpid
#         console.log current_customer_jpid
#         new_request_id = 
#             Docs.insert 
#                 type:'cart_item'
#                 service_id:@_id
#                 service_title:@title
#                 service_slug:@slug
#                 customer_jpid:current_customer_jpid
#         FlowRouter.go "/edit/#{new_request_id}"
#         Meteor.call 'calculate_request_count', @_id
