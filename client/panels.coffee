Template.incidents_panel.onCreated ->
    @autorun -> Meteor.subscribe 'demo_type', 'incident'
Template.quickbooks_panel.onCreated ->
    @autorun -> Meteor.subscribe 'demo_type', 'finance'
Template.messages_panel.onCreated ->
    @autorun -> Meteor.subscribe 'demo_type', 'message'
Template.users_panel.onCreated ->
    @autorun -> Meteor.subscribe 'demo_users'
Template.purchases_panel.onCreated ->
    @autorun -> Meteor.subscribe 'demo_type', 'transaction'
Template.service_requests_panel.onCreated ->
    @autorun -> Meteor.subscribe 'demo_type', 'service'
Template.events_panel.onCreated ->
    @autorun -> Meteor.subscribe 'demo_type', 'event'


Template.quickbooks_panel.helpers
    invoice_docs: -> Docs.find type:'finance'
    
Template.events_panel.helpers
    event_docs: -> Docs.find type:'event'
    
    
    