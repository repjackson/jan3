FlowRouter.route '/services', action: ->
    BlazeLayout.render 'layout', main: 'services'

Template.services.onCreated () ->
    @autorun => Meteor.subscribe 'type', 'special_service'
Template.services.helpers
    service_docs: ->  
        Docs.find 
            type: "special_service"

Template.services.events
    'click .sync_services': ->
        Meteor.call 'sync_services', ->
            
    
    
        
Template.customers_by_service.helpers
    selector: ->  
        page_service = Docs.findOne FlowRouter.getParam('doc_id')
        return {
            type: "customer"
            master_licensee: page_service.service_name
            }
    
    
Template.users_by_service.helpers
    selector: ->  
        page_service = Docs.findOne FlowRouter.getParam('doc_id')
        return {
            "profile.service_name": page_service.service_name
            }
    
    
    
    
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


