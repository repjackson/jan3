FlowRouter.route '/admin_sections', 
    name:'admin_sections'
    action: ->
        BlazeLayout.render 'layout', 
            # sub_nav: 'dev_nav'
            main: 'admin_sections'


Template.admin_sections.onCreated ->
    @autorun => Meteor.subscribe 'facet', 
        selected_tags.array()
        selected_author_ids.array()
        selected_location_tags.array()
        selected_timestamp_tags.array()
        type='admin_section'
        author_id=null

Template.admin_sections.helpers
    admin_sections: ->  Docs.find { type:'admin_section'}


Template.admin_section_card.onCreated ->

Template.admin_section_card.helpers
    

# Template.admin_section_edit.onCreated ->
#     @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')

# Template.admin_section_edit.helpers
#     admin_section: -> Doc.findOne FlowRouter.getParam('doc_id')
    
Template.admin_section_edit.events
    'click #delete': ->
        template = Template.currentData()
        swal {
            title: 'Delete admin_section?'
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
                FlowRouter.go "/admin_sections"

