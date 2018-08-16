FlowRouter.route '/incidents', 
    action: -> BlazeLayout.render 'layout', main:'incidents'

FlowRouter.route '/customer_incidents', 
    action: -> BlazeLayout.render 'layout', main:'customer_incidents'

    

Template.add_incident_button.events
    'click #add_incident': ->
        user = Meteor.user()
        my_customer_ob = Meteor.user().users_customer()
        if my_customer_ob
            Meteor.call 'count_current_incident_number', (err,incident_count)=>
                if err then console.error err
                else
                    console.log incident_count
                    next_incident_number = incident_count + 1
                    new_incident_id = 
                        Docs.insert
                            type: 'incident'
                            incident_number: next_incident_number
                            franchisee_jpid: user.franchisee_jpid
                            office_jpid: user.office_jpid
                            customer_jpid: user.customer_jpid
                            customer_name: my_customer_ob.ev.CUST_NAME
                            incident_office_name: my_customer_ob.ev.MASTER_LICENSEE
                            incident_franchisee: my_customer_ob.ev.FRANCHISEE
                            level: 1
                            open: true
                            submitted: false
                    FlowRouter.go "/view/#{new_incident_id}"


Template.incident_view.onRendered ->
    # Meteor.setTimeout ->
    #     $('.ui.checkbox').checkbox()
    # #     $('.ui.tabular.menu .item').tab()
    # , 400
    # Meteor.setTimeout ->
    #     $('.ui.tabular.menu .item').tab()
    # , 500
    
    # $('.step').on('click', () ->
    #     $.tab('change tab', 'two')
    #     )
            
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
            when 'missed_service' then 'basic'
            when 'poor_service' then 'basic'
            when 'employee_issue' then 'basic'
            when 'other' then 'grey'


Template.incidents.onCreated ->
    Session.setDefault('query',null)
    @autorun -> Meteor.subscribe 'incidents', Session.get('query'), parseInt(Session.get('page_size')),Session.get('sort_key'), Session.get('sort_direction'), parseInt(Session.get('skip'))
    @autorun => Meteor.subscribe 'count', 'incident'



Template.incidents.helpers
    all_incidents: -> 
        Docs.find {
            type:'incident'
        },{ sort:"#{Session.get('sort_key')}":parseInt("#{Session.get('sort_direction')}") }
        
        
Template.customer_incidents.onCreated ->
    Session.set('query',null)
    Session.set('page_size',10)
    @autorun -> Meteor.subscribe 'my_customer_incidents', Session.get('query'), parseInt(Session.get('page_size')), Session.get('sort_key'), Session.get('sort_direction'), parseInt(Session.get('skip'))
    @autorun => Meteor.subscribe 'my_incident_count'
Template.customer_incidents.helpers
    customer_incidents: -> 
        Docs.find {
            type:'incident'
        },{ sort:"#{Session.get('sort_key')}":parseInt("#{Session.get('sort_direction')}") }


Template.incident_view.onCreated ->
    @autorun -> Meteor.subscribe 'type','incident_type'
    @autorun -> Meteor.subscribe 'type','rule'
    @autorun -> Meteor.subscribe 'incident', FlowRouter.getParam('doc_id')


Template.incident_view.onRendered ->
    target_username = FlowRouter.getQueryParam 'username'
    console.log 'target username?',target_username
    if target_username
        Bert.alert "Unassigning user: #{target_username}", 'info', 'growl-top-right'
        Meteor.call 'unassign_user_from_incident', FlowRouter.getParam('doc_id'), target_username
    # @autorun -> Meteor.subscribe 'office_from_incident_id', FlowRouter.getParam('doc_id')

Template.incident_view.helpers
    incident_type_docs: -> Docs.find type:'incident_type'
    can_submit: -> 
        user = Meteor.user()
        is_customer = user and user.roles and ('customer' in user.roles)
        @service_date and @incident_details and @incident_type and is_customer and not @submitted
    
    can_edit_core: ->
        user = Meteor.user()
        doc_id = FlowRouter.getParam 'doc_id'
        incident = Docs.findOne doc_id
        if user and user.roles and 'customer' in user.roles
            if incident.submitted is true
                return false
            else
                return true
        else
            return false
            
            
    feedback_doc: ->
        Docs.findOne
            type:'feedback_response'
            
    
Template.incident_view.events
    'click #submit_feedback': ->
        new_response_id = Docs.insert({type:'feedback_response', parent_id:FlowRouter.getParam('doc_id')})
        FlowRouter.go("/edit/#{new_response_id}")

    'click .submit': -> 
        doc_id = FlowRouter.getParam 'doc_id'
        incident = Docs.findOne doc_id
        
        incidents_office =
            Docs.findOne
                "ev.MASTER_LICENSEE": incident.incident_office_name
                type:'office'
        if incidents_office
            escalation_minutes = incidents_office["escalation_1_#{incident.incident_type}_hours"]
            Meteor.call 'create_event', doc_id, 'submit', "Incident will escalate in #{escalation_minutes} minutes according to #{incident.incident_office_name} initial rules."
            Meteor.call 'create_event', doc_id, 'submit', "Incident submitted. #{incidents_office["escalation_1_#{incident.incident_type}_primary_contact"]} and #{incidents_office["escalation_1_#{incident.incident_type}_secondary_contact"]} have been notified per #{incident.incident_office_name} rules."
        Docs.update doc_id,
            $set:
                submitted:true
                submitted_datetime: Date.now()
                last_updated_datetime: Date.now()
        Meteor.call 'assign_incident_owner_after_submission', doc_id
        Meteor.call 'create_event', doc_id, 'submit', "submitted the incident."
        Meteor.call 'email_about_incident_submission', incident._id


    'click .unsubmit': -> 
        doc_id = FlowRouter.getParam 'doc_id'
        incident = Docs.findOne doc_id
        Docs.update doc_id,
            $set:
                submitted:false
                submitted_datetime: null
                updated: Date.now()
        Meteor.call 'create_event', doc_id, 'unsubmit', "unsubmitted the incident."
        
    'click .close_incident': ->
        doc_id = FlowRouter.getParam 'doc_id'
        incident = Docs.findOne doc_id
        
        $('.ui.confirm_close.modal').modal(
            inverted: false
            # transition: 'vertical flip'
            # observeChanges: true
            duration: 400
            onApprove : ()->
                Docs.update doc_id,
                    $set:
                        open:false
                        updated: Date.now()
                        closed_datetime: Date.now()
                Meteor.call 'create_event', doc_id, 'close', "closed the incident."
            ).modal('show')

       
    'click .reopen_incident': ->
        doc_id = FlowRouter.getParam 'doc_id'
        incident = Docs.findOne doc_id

        if confirm 'Reopen incident?'        
            Docs.update doc_id,
                $set:
                    open:true
                    # closed_datetime: Date.now()
                    updated: Date.now()
            Meteor.call 'create_event', doc_id, 'open', "reopened the incident."

       
       
    'click #run_single_escalation_check': ->
        Meteor.call 'single_escalation_check', FlowRouter.getParam 'doc_id', (err,res)->
            if err 
                console.dir err
                Bert.alert "#{err.reason}.", 'info', 'growl-top-right'
            else
                Bert.alert "#{res}.", 'success', 'growl-top-right'
        
    'click .remove_incident': ->
        swal {
            title: "Remove Incident?"
            # text: 'Confirm delete?'
            type: 'info'
            animation: false
            showCancelButton: true
            closeOnConfirm: true
            cancelButtonText: 'Cancel'
            confirmButtonText: 'Remove'
            confirmButtonColor: '#da5347'
        }, =>
            doc_id = FlowRouter.getParam('doc_id')
            Docs.remove doc_id
            Meteor.call 'clear_incident_events', doc_id, ->
            FlowRouter.go '/incidents'

        
# Template.incident_sla_widget.onRendered ->
    # Meteor.setTimeout( =>
    # $('.ui.report.modal').modal(
    #     transition: 'vertical flip'
    #     closable: true
    #     inverted: true
    #     onApprove : =>
    #         text = $('#thanks_message_text').val()
    #         Meteor.call 'create_message', recipient_id=self.data.author_id, text=text, parent_id=self.data._id, (err,res)->
    #             if err then console.error err
    #             else
    #                 $('#message_sent.modal').modal('show')
    #                 $('#thanks_message_text').val('')
    # )
    #         # ), 500            

Template.incident_sla_widget.helpers
    sla_rule_docs: -> Docs.find {type:'rule'}, sort:number:1
    incident_doc: ->
        doc_id = FlowRouter.getParam('doc_id')
        incident = Docs.findOne doc_id

Template.sla_rule_doc.helpers
    is_initial: -> @number is 1   

    can_escalate: -> 
        doc_id = FlowRouter.getParam 'doc_id'
        incident = Docs.findOne doc_id
        return incident.level is (@number-1)
        
    is_level: -> 
        doc_id = FlowRouter.getParam('doc_id')
        incident = Docs.findOne doc_id
        if incident
            incident.level is (@number)
    escalation_level_card_class: ->
        doc_id = FlowRouter.getParam('doc_id')
        incident = Docs.findOne doc_id
        if incident
            if incident.level is @number 
                'raised green' 
            else
                ''
    incident_doc: ->
        doc_id = FlowRouter.getParam('doc_id')
        incident = Docs.findOne doc_id
    hours_value: ->
        doc_id = FlowRouter.getParam('doc_id')
        incident = Docs.findOne doc_id
        if incident and incident.office_jpid
            incident_office = Docs.findOne
                "ev.ID": incident.office_jpid
                type:'office'
            incident_office["escalation_#{@number}_#{incident.incident_type}_hours"]

    franchisee_toggle_value: ->
        doc_id = FlowRouter.getParam('doc_id')
        incident = Docs.findOne doc_id
        if incident and incident.office_jpid
            incident_office = Docs.findOne
                "ev.ID": incident.office_jpid
                type:'office'
            incident_office["escalation_#{@number}_#{incident.incident_type}_contact_franchisee"]
    
    primary_contact_value: ->
        doc_id = FlowRouter.getParam('doc_id')
        incident = Docs.findOne doc_id
        if incident and incident.office_jpid
            incident_office = Docs.findOne
                "ev.ID": incident.office_jpid
                type:'office'
            incident_office["escalation_#{@number}_#{incident.incident_type}_primary_contact"]

    
    secondary_contact_value: ->
        doc_id = FlowRouter.getParam('doc_id')
        incident = Docs.findOne doc_id
        if incident and incident.office_jpid
            incident_office = Docs.findOne
                "ev.ID": incident.office_jpid
                type:'office'
            incident_office["escalation_#{@number}_#{incident.incident_type}_secondary_contact"]


Template.sla_rule_doc.events
    'click .set_level': (e,t)->
        doc_id = FlowRouter.getParam('doc_id')
        incident = Docs.findOne doc_id
        type = incident.incident_type
        Meteor.call 'find_office_from_customer_jpid', incident.customer_jpid, (err,res)=>
            if err then console.error err
            else
                office_doc = res 
                # office_doc = Meteor.user().users_customer().parent_franchisee().parent_office()
                primary_contact_string =  "escalation_#{@number}_#{type}_primary_contact"
                secondary_contact_string =  "escalation_#{@number}_#{type}_secondary_contact"
                if primary_contact_string
                    primary_contact_target =
                        Meteor.users.findOne
                            username: office_doc["#{primary_contact_string}"]
                    primary_username = if primary_contact_target and primary_contact_target.username then primary_contact_target.username else ''
                if secondary_contact_string
                    secondary_contact_target =
                        Meteor.users.findOne( username: office_doc["#{secondary_contact_string}"] )
                    secondary_username = if secondary_contact_target and secondary_contact_target.username then secondary_contact_target.username else ''
                sla = @
                Docs.update doc_id,
                    $set: level:sla.number
                Meteor.call 'email_about_escalation', doc_id
                Meteor.call 'create_event', doc_id, 'level_change', "#{Meteor.user().username} changed level to #{@number}"
                # $(e.currentTarget).closest('.ui.incident.modal').modal(
                #     inverted: false
                #     # transition: 'vertical flip'
                #     # observeChanges: true
                #     duration: 400
                #     onApprove : ()=>
                #     ).modal('show')
                
                # swal {
                #     title: "Change Incident to Level #{@number}?"
                #     text: "This will alert the office primary contact #{primary_contact_string} #{primary_username} and secondary contact #{secondary_contact_string} #{secondary_username}."
                #     type: 'info'
                #     animation: false
                #     showCancelButton: true
                #     closeOnConfirm: true
                #     cancelButtonText: 'Cancel'
                #     confirmButtonText: 'Change'
                #     confirmButtonColor: '#da5347'
                # }, =>
                #     Docs.update doc_id,
                #         $set: level:@number
                #     Meteor.call 'create_event', doc_id, 'level_change', "#{Meteor.user().username} changed level to #{@number}"
            
            
Template.full_doc_history.onCreated ->
    @autorun =>  Meteor.subscribe 'child_docs', FlowRouter.getParam('doc_id')

Template.incident_tasks.helpers
    incident_tasks: ->
        Docs.find {
            type: 'incident_task'
            parent_id: FlowRouter.getParam 'doc_id'
        }, sort:timestamp:-1


Template.incident_tasks.events
    'click #add_incident_task': ->
        new_incident_task_id = 
            Docs.insert
                type: 'incident_task'
                parent_id: FlowRouter.getParam 'doc_id'
        FlowRouter.go "/edit/#{new_incident_task_id}"
        
        
        
Template.incident_task_edit.onCreated ->
    @autorun -> Meteor.subscribe 'type','action'
        
Template.incident_task_edit.helpers
    incident: -> Doc.findOne FlowRouter.getParam 'doc_id'
    action_docs: -> Docs.find type:'action'
    