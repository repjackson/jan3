FlowRouter.route '/incidents', 
    action: -> BlazeLayout.render 'layout', main:'incidents'

FlowRouter.route '/customer_incidents', 
    action: -> BlazeLayout.render 'layout', main:'customer_incidents'

Template.incident_view.onCreated ->
    @autorun -> Meteor.subscribe 'incident', FlowRouter.getParam('doc_id')
    

Template.add_incident_button.events
    'click #add_incident': ->
        my_customer_ob = Meteor.user().users_customer()
        console.log my_customer_ob
        if my_customer_ob
            new_incident_id = 
                Docs.insert
                    type: 'incident'
                    customer_jpid: my_customer_ob.ev.ID
                    customer_name: my_customer_ob.ev.CUST_NAME
                    incident_office_name: my_customer_ob.ev.MASTER_LICENSEE
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
    #     console.log 'hi'
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


Template.incidents.helpers
    settings: ->
        collection: 'incidents'
        rowsPerPage: 20
        showFilter: true
        showRowCount: true
        # showColumnToggles: true
        fields: [
            { key: 'customer_name', label: 'Customer' }
            { key: 'incident_office_name', label: 'Office' }
            { key: '', label: 'Type', tmpl:Template.incident_type_label }
            { key: 'when', label: 'Logged' }
            { key: 'incident_details', label: 'Details' }
            { key: 'level', label: 'Level' }
            { key: '', label: 'Assigned To', tmpl:Template.associated_users }
            { key: '', label: 'Actions Taken', tmpl:Template.small_doc_history }
            { key: '', label: 'View', tmpl:Template.view_button }
        ]

Template.customer_incidents.onCreated ->
    @autorun -> Meteor.subscribe 'my_customer_incidents'

Template.customer_incidents.helpers
    customer_incidents: -> Docs.find type:'incident'
    settings: ->
        rowsPerPage: 20
        showFilter: true
        showRowCount: true
        # showColumnToggles: true
        fields: [
            { key: 'customer_name', label: 'Customer' }
            { key: 'incident_office_name', label: 'Office' }
            { key: '', label: 'Type', tmpl:Template.incident_type_label }
            { key: 'when', label: 'Logged' }
            { key: 'incident_details', label: 'Details' }
            { key: 'level', label: 'Level' }
            { key: '', label: 'Assigned To', tmpl:Template.associated_users }
            { key: '', label: 'Actions Taken', tmpl:Template.small_doc_history }
            { key: '', label: 'View', tmpl:Template.view_button }
        ]

Template.incident_view.onCreated ->
    @autorun -> Meteor.subscribe 'type','incident_type'
    @autorun -> Meteor.subscribe 'type','rule'

Template.incident_view.helpers
    incident_type_docs: -> Docs.find type:'incident_type'
    can_submit: -> @service_date and @incident_details and @incident_type
    
    
Template.incident_sla_widget.helpers
    can_escalate: -> 
        doc_id = FlowRouter.getParam('doc_id')
        incident = Docs.findOne doc_id
        console.log @number
        console.log incident.level
        console.log incident.level is (@number+1)
        return incident.level is (@number+1)
    is_level: -> 
        doc_id = FlowRouter.getParam('doc_id')
        incident = Docs.findOne doc_id
        # console.log @number
        # console.log incident.level
        # console.log incident.level is @number
        if incident
            incident.level is @number
    escalation_level_card_class: ->
        doc_id = FlowRouter.getParam('doc_id')
        incident = Docs.findOne doc_id
        # console.log @number
        # console.log incident.level
        # console.log incident.level is @number
        if incident
            if incident.level is @number 
                'raised green' 
            else
                ''
    incident_doc: ->
        doc_id = FlowRouter.getParam('doc_id')
        incident = Docs.findOne doc_id

    sla_rule_docs: -> Docs.find type:'rule'
    
    hours_value: -> 
        user = Meteor.user()
        if user and user.profile and user.profile.customer_jpid
            customer_doc = Docs.findOne
                "ev.ID": user.profile.customer_jpid
                type:'customer'
            if customer_doc
                users_office = Docs.findOne
                    "ev.MASTER_LICENSEE": customer_doc.ev.MASTER_LICENSEE
                    type:'office'
                users_office["escalation_#{@number}_hours"]

    primary_franchisee_toggle_value: ->
        user = Meteor.user()
        if user and user.profile and user.profile.customer_jpid
            customer_doc = Docs.findOne
                "ev.ID": user.profile.customer_jpid
                type:'customer'
            if customer_doc
                users_office = Docs.findOne
                    "ev.MASTER_LICENSEE": customer_doc.ev.MASTER_LICENSEE
                    type:'office'
                users_office["escalation_#{@number}_primary_contact_franchisee"]
    
    primary_contact_value: -> 
        user = Meteor.user()
        if user and user.profile and user.profile.customer_jpid
            customer_doc = Docs.findOne
                "ev.ID": user.profile.customer_jpid
                type:'customer'
            if customer_doc 
                users_office = Docs.findOne
                    "ev.MASTER_LICENSEE": customer_doc.ev.MASTER_LICENSEE
                    type:'office'
                users_office["escalation_#{@number}_primary_contact"]

    secondary_franchisee_toggle_value: ->
        user = Meteor.user()
        if user and user.profile and user.profile.customer_jpid
            customer_doc = Docs.findOne
                "ev.ID": user.profile.customer_jpid
                type:'customer'
            if customer_doc
                users_office = Docs.findOne
                    "ev.MASTER_LICENSEE": customer_doc.ev.MASTER_LICENSEE
                    type:'office'
                users_office["escalation_#{@number}_secondary_contact_franchisee"]
    
    
    secondary_contact_value: -> 
        user = Meteor.user()
        if user and user.profile and user.profile.customer_jpid
            customer_doc = Docs.findOne
                "ev.ID": user.profile.customer_jpid
                type:'customer'
            if customer_doc
                users_office = Docs.findOne
                    "ev.MASTER_LICENSEE": customer_doc.ev.MASTER_LICENSEE
                    type:'office'
                users_office["escalation_#{@number}_secondary_contact"]

    


Template.incident_sla_widget.events
    'click .set_level': ->
        console.log @
        doc_id = FlowRouter.getParam('doc_id')
        incident = Docs.findOne doc_id
        office_doc = Meteor.user().users_customer().parent_franchisee().parent_office()
        primary_contact_type =  office_doc.escalation_one_primary_contact
        secondary_contact_type =  office_doc.escalation_one_secondary_contact
        # console.log parent_doc["#{context.key}"]
        # console.log parent_doc[parent_doc["#{context.key}"]]
        if primary_contact_type
            primary_contact_target =
                Meteor.users.findOne
                    username: office_doc["#{primary_contact_type}"]
            primary_username = if primary_contact_target and primary_contact_target.username then primary_contact_target.username else ''
        if secondary_contact_type
            secondary_contact_target =
                Meteor.users.findOne( username: office_doc["#{secondary_contact_type}"] )
            secondary_username = if secondary_contact_target and secondary_contact_target.username then secondary_contact_target.username else ''
        swal {
            title: "Change Incident to Level #{@number}?"
            text: "This will alert the office primary contact #{primary_contact_type} #{primary_username} and secondary contact #{secondary_contact_type} #{secondary_username}."
            type: 'info'
            animation: false
            showCancelButton: true
            closeOnConfirm: true
            cancelButtonText: 'Cancel'
            confirmButtonText: 'Change'
            confirmButtonColor: '#da5347'
        }, =>
            Docs.update doc_id,
                $set: level:@number
            Meteor.call 'create_event', doc_id, 'level_change', "#{Meteor.user().username} changed level to #{@number}"
            
Template.full_doc_history.onCreated ->
    @autorun =>  Meteor.subscribe 'child_docs', FlowRouter.getParam('doc_id')

Template.incident_tasks.helpers
    incident_tasks: ->
        Docs.find
            type: 'incident_task'
            parent_id: FlowRouter.getParam('doc_id')

Template.incident_tasks.events
    'click #add_incident_task': ->
        new_incident_task_id = 
            Docs.insert
                type: 'incident_task'
                parent_id: FlowRouter.getParam('doc_id')
        FlowRouter.go "/edit/#{new_incident_task_id}"
        
        
        
Template.incident_task_edit.onCreated ->
    @autorun -> Meteor.subscribe 'docs', [], 'action'
        
Template.incident_task_edit.helpers
    incident: -> Doc.findOne FlowRouter.getParam('doc_id')
    action_docs: -> Docs.find type:'action'
    