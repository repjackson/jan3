FlowRouter.route '/services', action: ->
    BlazeLayout.render 'layout', main: 'services'

Template.services.onCreated ->
    @autorun => Meteor.subscribe 'type', 'service'

Template.services.helpers
    services: -> Docs.find type:'service'

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

