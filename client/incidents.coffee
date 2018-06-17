FlowRouter.route '/incidents', 
    action: ->
        BlazeLayout.render 'layout', main: 'incidents'


Template.incidents.events
    'click #add_incident': ->
        new_incident_id = 
            Docs.insert
                type: 'incident'
                customer_jpid: Meteor.user().profile.customer_jpid
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


Template.incidents.onCreated ->
Template.incidents.helpers
    selector: ->  type: "incident"



Template.incident_view.onCreated ->
    @autorun -> Meteor.subscribe 'docs', [], 'incident_type'

Template.incident_view.helpers
    incident_type_docs: -> Docs.find type:'incident_type'
    can_submit: -> @service_date and @incident_details and @incident_type
    can_set_to_one: -> @current_level is 2
    can_set_to_two: -> @current_level is 1
    
    
Template.incident_view.events
    'click .set_level_one': ->
        doc_id = FlowRouter.getParam('doc_id')
        incident = Docs.findOne doc_id
        # console.log @
        Docs.update doc_id,
            $set: current_level:1
        Meteor.call 'create_event', doc_id, 'level_change', "#{Meteor.user().username} changed level to 1"
            
    'click .set_level_two': ->
        doc_id = FlowRouter.getParam('doc_id')
        incident = Docs.findOne doc_id
        # console.log @
        Docs.update doc_id,
            $set: current_level:2
        office_doc = Meteor.user().users_customer.parent_franchisee.parent_office
        console.log office_doc
        # console.log parent_doc["#{context.key}"]
        # console.log parent_doc[parent_doc["#{context.key}"]]
        if office_doc.escalation_one_primary_contact
            contact_target =
                Meteor.users.findOne
                    username: office_doc[office_doc.escalation_one_primary_contact]
            console.log contact_target
        
        Meteor.call 'create_event', doc_id, 'level_change', "#{Meteor.user().username} changed level to 2"

    'click #delete': ->
        template = Template.currentData()
        swal {
            title: 'Delete Incident?'
            # text: 'Confirm delete?'
            type: 'error'
            animation: false
            showCancelButton: true
            closeOnConfirm: true
            cancelButtonText: 'Cancel'
            confirmButtonText: 'Delete'
            confirmButtonColor: '#da5347'
        }, =>
            doc = Docs.findOne FlowRouter.getParam('doc_id')
            # console.log doc
            Docs.remove doc._id, ->
                FlowRouter.go "/incidents"


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
    