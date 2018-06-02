if Meteor.isClient
    Template.customer_view.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    Template.customer_view.helpers
    
    
    FlowRouter.route '/customers', action: ->
        BlazeLayout.render 'layout', main: 'customers'
    
    
    @selected_customer_tags = new ReactiveArray []
    
    Template.customers.onCreated ->
        @autorun => Meteor.subscribe 'has_key', 'CUSTOMER' 
        
        # @autorun => Meteor.subscribe 'facet', 
        #     selected_tags.array()
        #     selected_keywords.array()
        #     selected_author_ids.array()
        #     selected_location_tags.array()
        #     selected_timestamp_tags.array()
        #     type='customer'
        #     author_id=null
    Template.customers.helpers
        customers: ->  Docs.find {}
        # customers: ->  Docs.find 'FRANCH_NAME':$exists:true


    Template.customer_card.onCreated ->
        GoogleMaps.ready('exampleMap', (map)->
            marker = new google.maps.Marker
                position: map.options.center
                map: map.instance
        )

    Template.customer_card.helpers
        exampleMapOptions: ()->
            # console.log @
            if GoogleMaps.loaded()
                return {
                    center: new google.maps.LatLng( @location_lat, @location_lng),
                    zoom: 8
                }

    
    Template.customer_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    
    Template.customer_edit.helpers
        customer: -> Doc.findOne FlowRouter.getParam('doc_id')
        
    Template.customer_edit.events
        'click #delete': ->
            template = Template.currentData()
            swal {
                title: 'Delete customer?'
                # text: 'Confirm delete?'
                type: 'error'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'Cancel'
                confirmButtonText: 'Delete'
                confirmButtonColor: '#da5347'
            }, =>
                doc = Docs.findOne FlowRouter.getParam('doc_id')
                # console.log doc
                Docs.remove doc._id, ->
                    FlowRouter.go "/customers"


