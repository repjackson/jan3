FlowRouter.route '/store', action: ->
    BlazeLayout.render 'layout', main: 'store'

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
