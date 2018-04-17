Template.incident_page.onCreated ->
    @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')



Template.incident_page.helpers
    incident: -> Docs.findOne FlowRouter.getParam('doc_id')


Template.incident_page.events
    'click .edit_incident': ->
        FlowRouter.go "/incident/edit/#{@_id}"
