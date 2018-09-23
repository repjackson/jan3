Template.add_ticket_button.events
    'click #add_ticket': ->
        Meteor.call 'log_ticket', (err,res)->
            if err then console.error err
            else
                FlowRouter.go "/p/submit_ticket?doc_id=#{res}"


Template.ticket_type_label.onRendered ->
    Meteor.setTimeout ->
        $('img').popup()
    , 2000

Template.ticket_type_label.helpers
    ticket_type_label: ->
        switch @ticket_type
            when 'missed_service' then 'Missed Service'
            when 'team_member_infraction' then 'Team Member Infraction'
            when 'change_service' then 'Request a Change of Service'
            when 'problem' then 'Report a Problem or Service Issue'
            when 'special_request' then 'Request a Special Service'
            when 'other' then 'Other'

    type_label_class: ->
        switch @ticket_type
            when 'missed_service' then 'blue'
            when 'team_member_infraction' then 'green'
            when 'change_service' then 'teal'
            when 'problem' then 'yellow'
            when 'special_request' then 'orange'
            when 'other' then 'grey'

    ticket_type_icon: ->
        switch @ticket_type
            when 'missed_service' then 'leave'
            when 'team_member_infraction' then 'unfriend-male'
            when 'change_service' then 'transfer-between-users'
            when 'problem' then 'box-important'
            when 'special_request' then 'carpet-cleaning'
            when 'other' then 'grey'

Template.level_icon.helpers
    is_level_one: -> @level is 1
    is_level_two: -> @level is 2
    is_level_three: -> @level is 3
    is_level_four: -> @level is 4




Template.submit_ticket.onCreated ->
    @autorun -> Meteor.subscribe 'type','ticket_type'
#     @autorun -> Meteor.subscribe 'type','rule'
#     @autorun -> Meteor.subscribe 'ticket', FlowRouter.getQueryParam('doc_id')


Template.submit_ticket.helpers
    ticket_type_docs: -> Docs.find type:'ticket_type'
    can_submit: ->
        ticket = Docs.findOne FlowRouter.getQueryParam('doc_id')
        user = Meteor.user()
        is_customer = user and user.roles and ('customer' in user.roles)
        ticket.service_date and ticket.ticket_details and ticket.ticket_type and is_customer

Template.submit_ticket.events
    'click .submit': ->
        doc_id = FlowRouter.getQueryParam 'doc_id'

        Meteor.call 'submit_ticket', doc_id, (err,res)->
        FlowRouter.go "/p/ticket_customer_view?doc_id=#{doc_id}"


Template.sla_tester.onCreated ->
    @autorun =>  Meteor.subscribe 'ticket_sla_docs', FlowRouter.getQueryParam('doc_id')
    @autorun =>  Meteor.subscribe 'office_employees_from_ticket_doc_id', FlowRouter.getQueryParam('doc_id')
Template.sla_tester.events
    'click .check_escalation': ->
        Meteor.call 'single_escalation_check', FlowRouter.getQueryParam('doc_id')

    'click .escalate_ticket': ->
        Meteor.call 'escalate_ticket', FlowRouter.getQueryParam('doc_id')

    'click .set_level': (e,t)->
        doc_id = FlowRouter.getQueryParam('doc_id')
        ticket = Docs.findOne doc_id
        type = ticket.ticket_type
        Docs.update doc_id,
            $set: level: @escalation_number

Template.sla_tester.helpers
    sla_docs: ->
        ticket = Docs.findOne FlowRouter.getQueryParam('doc_id')
        if ticket
            Docs.find {
                type:'sla_setting'
                office_jpid:ticket.office_jpid
                ticket_type:ticket.ticket_type
                }, sort:escalation_number:1

Template.view_sla_contact.helpers
    user_ob: ->
        Meteor.users.findOne
            username: @username
