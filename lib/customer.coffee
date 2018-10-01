if Meteor.isClient
    Template.customer_tickets.onCreated ->
        @autorun -> Meteor.subscribe 'customer_tickets', FlowRouter.getQueryParam('jpid')

    Template.customer_tickets.helpers
        customer_ticket_docs: -> Docs.find { type:'ticket'}



if Meteor.isServer
    Meteor.publish 'customer_tickets', (jpid) ->
        Docs.find
            type:'ticket'
            customer_jpid:jpid