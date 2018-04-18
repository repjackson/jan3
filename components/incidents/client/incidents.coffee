Template.view_incident.onCreated ->
    @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
Template.view_incident.helpers
    incident: -> Docs.findOne FlowRouter.getParam('doc_id')
Template.view_incident.events
    'click .edit_incident': -> FlowRouter.go "/edit/#{@_id}"




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

    'click .edit_incident': -> FlowRouter.go "/edit/#{@_id}"




Template.edit_incident.onCreated ->
    @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')

Template.edit_incident.helpers
    incident: -> Doc.findOne FlowRouter.getParam('doc_id')
    