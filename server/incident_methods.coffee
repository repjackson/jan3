Meteor.methods
    incident_assign_user_after_submission: (incident_doc_id)->
        incident_doc = Docs.findOne incident_doc_id
        incidents_office =
            Docs.findOne
                "ev.MASTER_LICENSEE": incident_doc.incident_office_name
                type:'office'
        if incidents_office
            default_value = incidents_office["escalation_#{incident_doc.incident_type}_default_contact"]
            if default_value
                assigned_user = Meteor.users.findOne username:default_value
                console.log 'assigned_user', assigned_user
                Docs.update incident_doc_id,
                    $addToSet: 
                        assigned_to: assigned_user._id
            else
                custom_initial_contact_value = incidents_office["escalation_1_#{incident_doc.incident_type}_primary_contact"]
                console.log 'custom_initial_contact_value', custom_initial_contact_value

            # escalation_minutes = incidents_office["escalation_1_#{incident.incident_type}_hours"]
            # Meteor.call 'create_event', doc_id, 'submit', "Incident will escalate in #{escalation_minutes} minutes according to #{incident.incident_office_name} initial rules."
        else
            throw new Meteor.Error 'no incident office found, cant run escalation rules'