if Meteor.isClient
    Template.office_view.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    Template.office_view.helpers
    
    
    FlowRouter.route '/offices', action: ->
        BlazeLayout.render 'layout', main: 'offices'
    
    
    @selected_office_tags = new ReactiveArray []
    
    Template.offices.onCreated ->
        @autorun => Meteor.subscribe 'facet', 
            selected_theme_tags.array()
            selected_keywords.array()
            selected_author_ids.array()
            selected_location_tags.array()
            selected_timestamp_tags.array()
            type='office'
            author_id=null
    Template.offices.helpers
        offices: ->  Docs.find { type:'office'}


    Template.office_card.onCreated ->
        GoogleMaps.ready('exampleMap', (map)->
            marker = new google.maps.Marker
                position: map.options.center
                map: map.instance
        )

    Template.office_card.helpers
        exampleMapOptions: ()->
            # console.log @
            if GoogleMaps.loaded()
                return {
                    center: new google.maps.LatLng( @location_lat, @location_lng),
                    zoom: 8
                }

    
    Template.office_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    
    Template.office_edit.helpers
        office: -> Doc.findOne FlowRouter.getParam('doc_id')
        
    Template.office_edit.events
        'click #delete': ->
            template = Template.currentData()
            swal {
                title: 'Delete office?'
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
                    FlowRouter.go "/offices"


