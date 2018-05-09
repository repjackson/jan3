if Meteor.isClient
    FlowRouter.route '/store', action: ->
        BlazeLayout.render 'layout', main: 'store'
    
    Template.store.onCreated ->
        @autorun => Meteor.subscribe 'facet', 
            selected_tags.array()
            selected_keywords.array()
            selected_author_ids.array()
            selected_location_tags.array()
            selected_timestamp_tags.array()
            type='product'
            author_id=null
    
    Template.store.helpers
        products: ->
            Docs.find
                type:'product'
    
    
    Template.store.events
        'keydown #new_product': (e,t)->
            if e.which is 13
                new_product = $('#new_product').val().trim()
                if new_product.length > 0
                    Docs.insert 
                        text: new_product
                        type:'product'
                    $('#new_product').val('')

    Template.product.events
        'click .delete_comment': ->
            if confirm 'Delete comment?'
                Docs.remove @_id

