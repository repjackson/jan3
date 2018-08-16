Meteor.methods
    assign_incident_owner_after_submission: (incident_doc_id)->
        console.log incident_doc_id
        incident_doc = Docs.findOne incident_doc_id
        console.log incident_doc
        incidents_office =
            Docs.findOne
                "ev.MASTER_LICENSEE": incident_doc.incident_office_name
                type:'office'
        console.log incidents_office
        if incidents_office
            incident_owner = incidents_office["#{incident_doc.incident_type}_incident_owner"]
            console.log incident_owner
            if incident_owner
                assigned_user = Meteor.users.findOne username:incident_owner
                console.log 'assigned_user', assigned_user
                Docs.update incident_doc_id,
                    $addToSet: 
                        assigned_to: assigned_user._id

            # escalation_minutes = incidents_office["escalation_1_#{incident.incident_type}_hours"]
            # Meteor.call 'create_event', doc_id, 'submit', "Incident will escalate in #{escalation_minutes} minutes according to #{incident.incident_office_name} initial rules."
        else
            throw new Meteor.Error 'no incident office found, cant run escalation rules'