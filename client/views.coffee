Template.comments_view.onCreated ->
    @autorun =>  Meteor.subscribe 'type', 'event_type'


Template.message_type.helpers
    is_sms: -> @message_type is 'sms'
    is_email: -> @message_type is 'email'

Template.recipient_type.helpers
    is_owner: -> @recipient_type is 'owner'
    is_secondary: -> @recipient_type is 'secondary'
    is_franchisee: -> @recipient_type is 'franchisee'
    is_customer: -> @recipient_type is 'customer'



Template.ticket_cell.onCreated ->
    @autorun =>  Meteor.subscribe 'doc', @data.ticket_id

Template.ticket_cell.helpers
    ticket: ->
        Docs.findOne
            type:'ticket'