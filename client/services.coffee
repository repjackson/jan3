FlowRouter.route '/services', action: ->
    BlazeLayout.render 'layout', main: 'services'

Template.services.onCreated () ->
Template.services.helpers
    settings: ->
        collection: 'services'
        rowsPerPage: 10
        showFilter: true
        showRowCount: true
        # showColumnToggles: true
        fields: [
            { key: 'title', label: 'Title' }
            { key: 'price', label: 'Price' }
            { key: '', label: 'View', tmpl:Template.view_button }
        ]

Template.services.events
    'click .sync_services': ->
        Meteor.call 'sync_services', ->
            
    
    
        
    
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

