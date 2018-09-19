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
    
#     can_edit_core: ->
#         user = Meteor.user()
#         doc_id = FlowRouter.getQueryParam 'doc_id'
#         incident = Docs.findOne doc_id
#         if user and user.roles and 'customer' in user.roles
#             if incident.submitted is true
#                 return false
#             else
#                 return true
#         else
#             return false
            
            
#     feedback_doc: ->
#         Docs.findOne
#             type:'feedback_response'
            
    
Template.submit_incident.events
    'click .submit': -> 
        doc_id = FlowRouter.getQueryParam 'doc_id'
        incident = Docs.findOne doc_id
        
        incidents_office =
            Docs.findOne
                "ev.MASTER_LICENSEE": incident.incident_office_name
                type:'office'
        if incidents_office
            escalation_hours = incidents_office["escalation_1_#{incident.incident_type}_hours"]
            Meteor.call 'create_event', doc_id, 'submit', "Incident will escalate in #{escalation_hours} hours according to #{incident.incident_office_name} initial rules."
            Meteor.call 'create_event', doc_id, 'submit', "Incident submitted. #{incidents_office["escalation_1_#{incident.incident_type}_primary_contact"]} and #{incidents_office["escalation_1_#{incident.incident_type}_secondary_contact"]} have been notified per #{incident.incident_office_name} rules."
        Docs.update doc_id,
            $set:
                submitted:true
                submitted_datetime: Date.now()
                last_updated_datetime: Date.now()
        Meteor.call 'assign_incident_owner_after_submission', doc_id
        Meteor.call 'create_event', doc_id, 'submit', "submitted the incident."
        Meteor.call 'email_about_incident_submission', incident._id

        FlowRouter.go "/p/incident_customer_view?doc_id=#{doc_id}"

#     'click .unsubmit': -> 
#         doc_id = FlowRouter.getQueryParam 'doc_id'
#         incident = Docs.findOne doc_id
#         Docs.update doc_id,
#             $set:
#                 submitted:false
#                 submitted_datetime: null
#                 updated: Date.now()
#         Meteor.call 'create_event', doc_id, 'unsubmit', "unsubmitted the incident."
        
#     'click .close_incident': ->
#         doc_id = FlowRouter.getQueryParam 'doc_id'
#         incident = Docs.findOne doc_id
        
#         $('.ui.confirm_close.modal').modal(
#             inverted: false
#             # transition: 'vertical flip'
#             # observeChanges: true
#             duration: 400
#             onApprove : ()->
#                 Docs.update doc_id,
#                     $set:
#                         open:false
#                         updated: Date.now()
#                         closed_datetime: Date.now()
#                 Meteor.call 'create_event', doc_id, 'close', "closed the incident."
#             ).modal('show')

       
#     'click .reopen_incident': ->
#         doc_id = FlowRouter.getQueryParam 'doc_id'
#         incident = Docs.findOne doc_id

#         if confirm 'Reopen incident?'        
#             Docs.update doc_id,
#                 $set:
#                     open:true
#                     # closed_datetime: Date.now()
#                     updated: Date.now()
#             Meteor.call 'create_event', doc_id, 'open', "reopened the incident."

       
       
#     'click #run_single_escalation_check': ->
#         Meteor.call 'single_escalation_check', FlowRouter.getQueryParam 'doc_id', (err,res)->
#             if err 
#                 console.dir err
#             else
        
#     'click .remove_incident': ->
#         swal {
#             title: "Remove Incident?"
#             # text: 'Confirm delete?'
#             type: 'info'
#             animation: false
#             showCancelButton: true
#             closeOnConfirm: true
#             cancelButtonText: 'Cancel'
#             confirmButtonText: 'Remove'
#             confirmButtonColor: '#da5347'
#         }, =>
#             doc_id = FlowRouter.getQueryParam('doc_id')
#             Docs.remove doc_id
#             Meteor.call 'clear_incident_events', doc_id, ->
#             FlowRouter.go '/p/admin_incidents'

        

Template.incident_sla_widget.helpers
    sla_rule_docs: -> Docs.find {type:'rule'}, sort:number:1
    incident_doc: ->
        doc_id = FlowRouter.getQueryParam('doc_id')
        incident = Docs.findOne doc_id

Template.sla_rule_doc.helpers
    is_initial: -> @number is 1   

    can_escalate: -> 
        doc_id = FlowRouter.getQueryParam 'doc_id'
        incident = Docs.findOne doc_id
        return incident.level is (@number-1)
        
    is_level: -> 
        doc_id = FlowRouter.getQueryParam('doc_id')
        incident = Docs.findOne doc_id
        if incident
            incident.level is (@number)
    escalation_level_card_class: ->
        doc_id = FlowRouter.getQueryParam('doc_id')
        incident = Docs.findOne doc_id
        if incident
            if incident.level is @number 
                'raised green' 
            else
                ''
    incident_doc: ->
        doc_id = FlowRouter.getQueryParam('doc_id')
        incident = Docs.findOne doc_id


Template.sla_rule_doc.events
    'click .set_level': (e,t)->
        console.log @
        doc_id = FlowRouter.getQueryParam('doc_id')
        incident = Docs.findOne doc_id
        type = incident.incident_type
        Docs.update doc_id,
            $set: level: @
        # Meteor.call 'find_office_from_customer_jpid', incident.customer_jpid, (err,res)=>
        #     if err then console.error err
        #     else
        #         office_doc = res 
        #         # office_doc = Meteor.user().users_customer().parent_franchisee().parent_office()
        #         primary_contact_string =  "escalation_#{@number}_#{type}_primary_contact"
        #         secondary_contact_string =  "escalation_#{@number}_#{type}_secondary_contact"
        #         if primary_contact_string
        #             primary_contact_target =
        #                 Meteor.users.findOne
        #                     username: office_doc["#{primary_contact_string}"]
        #             primary_username = if primary_contact_target and primary_contact_target.username then primary_contact_target.username else ''
        #         if secondary_contact_string
        #             secondary_contact_target =
        #                 Meteor.users.findOne( username: office_doc["#{secondary_contact_string}"] )
        #             secondary_username = if secondary_contact_target and secondary_contact_target.username then secondary_contact_target.username else ''
        #         sla = @
        #         Docs.update doc_id,
        #             $set: level:sla.number
        #         Meteor.call 'email_about_escalation', doc_id
        #         Meteor.call 'create_event', doc_id, 'level_change', "#{Meteor.user().username} changed level to #{@number}"
        #         # $(e.currentTarget).closest('.ui.incident.modal').modal(
        #         #     inverted: false
        #         #     # transition: 'vertical flip'
        #         #     # observeChanges: true
        #         #     duration: 400
        #         #     onApprove : ()=>
        #         #     ).modal('show')
                
        #         # swal {
        #         #     title: "Change Incident to Level #{@number}?"
        #         #     text: "This will alert the office primary contact #{primary_contact_string} #{primary_username} and secondary contact #{secondary_contact_string} #{secondary_username}."
        #         #     type: 'info'
        #         #     animation: false
        #         #     showCancelButton: true
        #         #     closeOnConfirm: true
        #         #     cancelButtonText: 'Cancel'
        #         #     confirmButtonText: 'Change'
        #         #     confirmButtonColor: '#da5347'
        #         # }, =>
        #         #     Docs.update doc_id,
        #         #         $set: level:@number
        #         #     Meteor.call 'create_event', doc_id, 'level_change', "#{Meteor.user().username} changed level to #{@number}"
            
            
Template.full_doc_history.onCreated ->
    @autorun =>  Meteor.subscribe 'child_docs', FlowRouter.getQueryParam('doc_id')

    
    


Template.sla_tester.onCreated ->
    @autorun =>  Meteor.subscribe 'incident_sla_docs', FlowRouter.getQueryParam('doc_id')
    @autorun =>  Meteor.subscribe 'office_employees_from_incident_doc_id', FlowRouter.getQueryParam('doc_id')
Template.sla_tester.events
    'click .check_escalation': ->
        Meteor.call 'single_escalation_check', FlowRouter.getQueryParam('doc_id')
                
        
    'click .escalate_incident': ->
        Meteor.call 'escalate_incident', FlowRouter.getQueryParam('doc_id')
        
    'click .set_level': (e,t)->
        console.log @
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
            