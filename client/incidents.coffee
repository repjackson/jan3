Template.add_incident_button.events
    'click #add_incident': ->
        Meteor.call 'log_ticket', (err,res)->
            if err then console.error err
            else
                FlowRouter.go "/p/submit_incident?doc_id=#{res}"


Template.incident_type_label.onRendered ->
    Meteor.setTimeout ->
        $('img').popup()
    , 2000

Template.incident_type_label.helpers
    incident_type_label: ->
        switch @incident_type
            when 'missed_service' then 'Missed Service'
            when 'team_member_infraction' then 'Team Member Infraction'
            when 'change_service' then 'Request a Change of Service'
            when 'problem' then 'Report a Problem or Service Issue'
            when 'special_request' then 'Request a Special Service'
            when 'other' then 'Other'
    
    type_label_class: ->
        switch @incident_type
            when 'missed_service' then 'blue'
            when 'team_member_infraction' then 'green'
            when 'change_service' then 'teal'
            when 'problem' then 'yellow'
            when 'special_request' then 'orange'
            when 'other' then 'grey'
    
    incident_type_icon: ->
        switch @incident_type
            when 'missed_service' then 'leave'
            when 'team_member_infraction' then 'unfriend-male'
            when 'change_service' then 'transfer-between-users'
            when 'problem' then 'box-important'
            when 'special_request' then 'carpet-cleaning'
            when 'other' then 'grey'

Template.level_icon.helpers
    level_icon_name: ->
        switch @level
            when 1 then '1-c'
            when 2 then '2-c'
            when 3 then '3-c'
            when 4 then '4-c'

    is_level_one: -> @level is 1
    is_level_two: -> @level is 2
    is_level_three: -> @level is 3
    is_level_four: -> @level is 4



Template.submit_incident.onCreated ->
    @autorun -> Meteor.subscribe 'type','incident_type'
#     @autorun -> Meteor.subscribe 'type','rule'
#     @autorun -> Meteor.subscribe 'incident', FlowRouter.getQueryParam('doc_id')


# Template.submit_incident.onRendered ->
#     target_username = FlowRouter.getQueryParam 'username'
#     if target_username
#         Meteor.call 'unassign_user_from_incident', FlowRouter.getQueryParam('doc_id'), target_username, (err,res)->
#             if err then console.error err
#             else
#     # @autorun -> Meteor.subscribe 'office_from_incident_id', FlowRouter.getQueryParam('doc_id')

Template.submit_incident.helpers
    incident_type_docs: -> Docs.find type:'incident_type'
    can_submit: -> 
        incident_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
        user = Meteor.user()
        is_customer = user and user.roles and ('customer' in user.roles)
        incident_doc.service_date and incident_doc.incident_details and incident_doc.incident_type and is_customer
    
Template.submit_incident.events
    'click .submit': -> 
        doc_id = FlowRouter.getQueryParam 'doc_id'

        Meteor.call 'submit_incident', doc_id, (err,res)->
        FlowRouter.go "/p/incident_customer_view?doc_id=#{doc_id}"


Template.sla_tester.onCreated ->
    @autorun =>  Meteor.subscribe 'incident_sla_docs', FlowRouter.getQueryParam('doc_id')
    @autorun =>  Meteor.subscribe 'office_employees_from_incident_doc_id', FlowRouter.getQueryParam('doc_id')
Template.sla_tester.events
    'click .check_escalation': ->
        Meteor.call 'single_escalation_check', FlowRouter.getQueryParam('doc_id')
                
        
    'click .escalate_incident': ->
        Meteor.call 'escalate_incident', FlowRouter.getQueryParam('doc_id')
        
    'click .set_level': (e,t)->
        doc_id = FlowRouter.getQueryParam('doc_id')
        incident = Docs.findOne doc_id
        type = incident.incident_type
        Docs.update doc_id,
            $set: level: @escalation_number
            
Template.sla_tester.helpers
    sla_docs: -> 
        incident = Docs.findOne FlowRouter.getQueryParam('doc_id')
        if incident
            Docs.find {
                type:'sla_setting'
                office_jpid:incident.office_jpid
                incident_type:incident.incident_type
                }, sort:escalation_number:1

Template.view_sla_contact.helpers
    user_ob: ->
        Meteor.users.findOne
            username: @username
            