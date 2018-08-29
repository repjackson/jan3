Template.event_types.onCreated ->
    @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
Template.event_types.helpers


FlowRouter.route '/event_types', 
    name:'event_types'
    action: ->
        BlazeLayout.render 'layout', 
            # sub_nav: 'dev_nav'
            main: 'event_types'


Template.event_types.onCreated ->
    @autorun => Meteor.subscribe 'facet', 
        selected_tags.array()
        selected_author_ids.array()
        selected_location_tags.array()
        selected_timestamp_tags.array()
        type='event_type'
        author_id=null

Template.event_types.helpers
    event_types: ->  Docs.find { type:'event_type'}


Template.event_type_card.onCreated ->

Template.event_type_card.helpers
    

# Template.event_type_edit.onCreated ->
#     @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')

# Template.event_type_edit.helpers
#     event_type: -> Doc.findOne FlowRouter.getParam('doc_id')
    
Template.event_type_edit.events
    'click #delete': ->
        template = Template.currentData()
        swal {
            title: 'Delete event_type?'
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
                FlowRouter.go "/event_types"

