FlowRouter.route '/services', action: ->
    BlazeLayout.render 'layout', main: 'services'

Template.services.onCreated ->
    @autorun => Meteor.subscribe 'type', 'service'

Template.services.helpers
    services: -> Docs.find type:'service'

Template.request_service_button.events
    'click .request_service': ->
        console.log @
        new_request_id = 
            Docs.insert 
                type:'service_request'
                service_id:@_id
                service_title:@title
                service_slug:@slug
        FlowRouter.go "/edit/#{new_request_id}"


Template.services.onCreated ->
    @autorun => Meteor.subscribe 'service_child_requests', FlowRouter.getParam('doc_id')

Template.service_child_requests.helpers
    child_requests: ->
        Docs.find type:'service_request'

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


Template.service_request_edit.events
    'click #delete': ->
        template = Template.currentData()
        swal {
            title: 'Delete Service Request?'
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

