if Meteor.isClient
    Template.office_view.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    Template.office_view.helpers
    
    
    FlowRouter.route '/offices', action: ->
        BlazeLayout.render 'layout', main: 'offices'
    
    
    @selected_office_tags = new ReactiveArray []
    
    Template.offices.onCreated ->
        @autorun -> Meteor.subscribe('docs',[],'office')
    Template.offices.helpers
        offices: ->  Docs.find { type:'office'}


    
    
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


    Template.google_places_input.onRendered ->
        input = document.getElementById('google_places_field');
        options = {}
            # types: ['(cities)'],
            # componentRestrictions: {country: 'fr'}
        
        @autocomplete = new google.maps.places.Autocomplete(input, options);
    
    Template.google_places_input.events
        'change #google_places_field': (e,t)->
            console.log t
            place = t.autocomplete.getPlace();
            console.log place