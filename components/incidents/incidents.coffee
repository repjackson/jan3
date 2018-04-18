if Meteor.isClient
    Template.incident_view.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    Template.incident_view.helpers
        incident: -> Docs.findOne FlowRouter.getParam('doc_id')
    Template.incident_view.events
        'click .incident_edit': -> FlowRouter.go "/edit/#{@_id}"
    
    
    FlowRouter.route '/incidents', action: ->
        BlazeLayout.render 'layout', main: 'incidents'
    
    
    @selected_incident_tags = new ReactiveArray []
    
    Template.incidents.onCreated ->
        @autorun -> Meteor.subscribe('docs',[],'incident')
    Template.incidents.helpers
        incidents: ->  Docs.find { type:'incident'}
    Template.incidents.events
        'click #add_incident': -> 
            id = Docs.insert type:'incident'
            FlowRouter.go "/edit/#{id}"
    
    Template.incident.helpers
        tag_class: -> if @valueOf() in selected_incident_tags.array() then 'primary' else 'basic'
        can_edit: -> @author_id is Meteor.userId()
    Template.incident_item.helpers
        tag_class: -> if @valueOf() in selected_incident_tags.array() then 'primary' else 'basic'
        can_edit: -> @author_id is Meteor.userId()
    
    
    Template.incident.events
        'click .incident_tag': ->
            if @valueOf() in selected_incident_tags.array() then selected_incident_tags.remove @valueOf() else selected_incident_tags.push @valueOf()
    
        'click .incident_edit': -> FlowRouter.go "/edit/#{@_id}"
    
    
    
    
    Template.incident_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    
    Template.incident_edit.helpers
        incident: -> Doc.findOne FlowRouter.getParam('doc_id')
        
    Template.incident_edit.events
        'click #delete': ->
            template = Template.currentData()
            swal {
                title: 'Delete Incident?'
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
                    FlowRouter.go "/incidents"
