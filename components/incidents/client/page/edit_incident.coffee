Template.edit_incident.onCreated ->
    @autorun -> Meteor.subscribe 'incident', FlowRouter.getParam('incident_id')

Template.edit_incident.helpers
    incident: -> Incidents.findOne FlowRouter.getParam('incident_id')
    