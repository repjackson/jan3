if Meteor.isClient
    Template.event_view.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    Template.event_view.helpers
    
    
    FlowRouter.route '/schedule', action: ->
        BlazeLayout.render 'layout', main: 'schedule'
    
    
    @selected_event_tags = new ReactiveArray []
    
    Template.schedule.onCreated ->
        @autorun -> Meteor.subscribe('docs',[],'event')
    Template.schedule.helpers
        schedule: ->  Docs.find { type:'event'}


    
    
    Template.event_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    
    Template.event_edit.helpers
        event: -> Doc.findOne FlowRouter.getParam('doc_id')
        
    Template.event_edit.events
        'click #delete': ->
            template = Template.currentData()
            swal {
                title: 'Delete event?'
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
                    FlowRouter.go "/schedule"
