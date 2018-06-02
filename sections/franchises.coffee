if Meteor.isClient
    Template.franchise_view.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    Template.franchise_view.helpers
    
    
    FlowRouter.route '/franchises', action: ->
        BlazeLayout.render 'layout', main: 'franchises'
    
    
    @selected_franchise_tags = new ReactiveArray []
    
    Template.franchises.onCreated ->
        @autorun => Meteor.subscribe 'has_key', 'FRANCH_NAME' 
        
        # @autorun => Meteor.subscribe 'facet', 
        #     selected_tags.array()
        #     selected_keywords.array()
        #     selected_author_ids.array()
        #     selected_location_tags.array()
        #     selected_timestamp_tags.array()
        #     type='franchise'
        #     author_id=null
    Template.franchises.helpers
        franchises: ->  Docs.find {}
        # franchises: ->  Docs.find 'FRANCH_NAME':$exists:true


    Template.franchise_card.onCreated ->
        GoogleMaps.ready('exampleMap', (map)->
            marker = new google.maps.Marker
                position: map.options.center
                map: map.instance
        )

    Template.franchise_card.helpers
        exampleMapOptions: ()->
            # console.log @
            if GoogleMaps.loaded()
                return {
                    center: new google.maps.LatLng( @location_lat, @location_lng),
                    zoom: 8
                }

    
    Template.franchise_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    
    Template.franchise_edit.helpers
        franchise: -> Doc.findOne FlowRouter.getParam('doc_id')
        
    Template.franchise_edit.events
        'click #delete': ->
            template = Template.currentData()
            swal {
                title: 'Delete franchise?'
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
                    FlowRouter.go "/franchises"


