if Meteor.isClient
    FlowRouter.route '/incident_types', action: ->
        BlazeLayout.render 'layout', 
            sub_nav: 'admin_nav'
            main: 'incident_types'
    
    
    Template.incident_types.onCreated ->
        @autorun => Meteor.subscribe 'type', 'incident_type'
    Template.incident_types.helpers
        incident_types: ->  Docs.find { type:'incident_type'}


    Template.incident_type_card.onCreated ->

    Template.incident_type_card.helpers
        
    
    Template.incident_type_edit.onCreated ->
        # @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    
    Template.incident_type_edit.helpers
        incident_type: -> Doc.findOne FlowRouter.getParam('doc_id')
        
    Template.incident_type_edit.events
        'click #delete': ->
            template = Template.currentData()
            swal {
                title: 'Delete incident_type?'
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
                    FlowRouter.go "/incident_types"

