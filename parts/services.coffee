if Meteor.isClient
    Template.service_view.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    Template.service_view.helpers
    
    
    FlowRouter.route '/services', action: ->
        BlazeLayout.render 'layout', main: 'services'
    
    
    @selected_service_tags = new ReactiveArray []
    
    Template.services.onCreated ->
        @autorun -> Meteor.subscribe('docs',[],'service')
    Template.services.helpers
        services: ->  Docs.find { type:'service'}


    
    
    Template.service_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    
    Template.service_edit.helpers
        service: -> Doc.findOne FlowRouter.getParam('doc_id')
        
    Template.service_edit.events
        'click #delete': ->
            template = Template.currentData()
            swal {
                title: 'Delete service?'
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
                    FlowRouter.go "/services"
