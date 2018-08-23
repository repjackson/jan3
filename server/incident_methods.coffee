Meteor.methods
    assign_incident_owner_after_submission: (incident_doc_id)->
        # console.log incident_doc_id
        incident_doc = Docs.findOne incident_doc_id
        # console.log incident_doc
        incidents_office =
            Docs.findOne
                "ev.MASTER_LICENSEE": incident_doc.incident_office_name
                type:'office'
        # console.log incidents_office
        if incidents_office
            incident_owner = incidents_office["#{incident_doc.incident_type}_incident_owner"]
            # console.log incident_owner
            if incident_owner
                owner_user = Meteor.users.findOne username:incident_owner
                # console.log 'owner_user', owner_user
                Docs.update incident_doc_id,
                    $addToSet: assigned_to: owner_user._id
                    $set: assignment_timestamp:Date.now()
                # escalation_minutes = incidents_office["escalation_1_#{incident.incident_type}_hours"]
                Meteor.call 'create_event', incident_doc_id, 'assignment', "Owner #{owner_user.username} automatically assigned after submission."
                Meteor.call 'create_event', incident_doc_id, 'timestamp_update', "Assignment timestamp updated."
        else
            throw new Meteor.Error 'no incident office found, cant run escalation rules'
    
    
    
    unassign_user_from_incident: (incident_doc_id, username)->
        owner_user = Meteor.users.findOne username:username
        incident_doc = Docs.findOne incident_doc_id
        Docs.update incident_doc_id,
            $pull: assigned_to: owner_user._id
            $set: assignment_timestamp:Date.now()
        Meteor.call 'create_event', incident_doc_id, 'unassignment', "#{username} marked task complete and was unassigned."
        # assign owner if no one else
        updated_doc = Docs.findOne incident_doc_id
        console.log updated_doc.assigned_to.length
        if updated_doc.assigned_to.length is 0
            incident_office = Docs.findOne({type:'office', "ev.ID":updated_doc.office_jpid})
            owner_value = incident_office["#{incident_doc.incident_type}_incident_owner"]
            owner_user = Meteor.users.findOne username:owner_value
            Docs.update incident_doc_id, 
                $addToSet:assigned_to:[owner_user._id]
            Meteor.call 'create_event', incident_doc_id, 'assignment', "Owner #{username} reassigned after completed task by #{username}."
                
            
    update_escalation_statuses: ->
        open_incidents = Docs.find({type:'incident', open:true, submitted:true})
        open_incidents_count = open_incidents.count()
        Meteor.call 'create_event',null, 'start_escalation_check', "Starting esclation check."
        Meteor.call 'create_event',null, 'incident_count', "Found #{open_incidents_count} open incidents, checking escalation status."
        for incident in open_incidents.fetch()
            Meteor.call 'single_escalation_check', incident._id
         
    single_escalation_check: (incident_id)->
        incident = Docs.findOne incident_id
        if incident.level is 4
            return
            # Meteor.call 'create_event', incident_id, 'max_level_notice', "Incident is at max level 4, not escalating."
        else
            incident_office =
                Docs.findOne
                    "ev.MASTER_LICENSEE": incident.incident_office_name
                    type:'office'
            current_level = incident.level
            next_level = current_level + 1

            last_updated = incident.updated
            existing_hours_value = incident_office["escalation_#{next_level}_#{incident.incident_type}_hours"]
            if existing_hours_value 
                hours_value = existing_hours_value
            else 
                hours_value = 2
                Meteor.call 'create_event', incident_id, 'setting_default_escalation_time', "No escalation minutes found, using 2 as the default."
                
            now = Date.now()
            updated_now_difference = now-last_updated
            seconds_elapsed = Math.floor(updated_now_difference/1000)
            minutes_elapsed = Math.floor(seconds_elapsed/60)
            escalation_calculation = minutes_elapsed - hours_value
            if minutes_elapsed < hours_value
                Meteor.call 'create_event', incident_id, 'not-escalate', "#{minutes_elapsed} minutes have elapsed, less than #{hours_value} in level #{next_level} #{incident.incident_type} rules, not escalating."
                # continue
            else    
                Meteor.call 'create_event', incident_id, 'escalate', "#{minutes_elapsed} minutes have elapsed, more than #{hours_value} in level #{next_level} #{incident.incident_type} rules, escalating."
                Meteor.call 'escalate_incident', incident._id, ->
            
    escalate_incident: (doc_id)-> 
        incident = Docs.findOne doc_id
        current_level = incident.level
        if current_level > 3
            Docs.update doc_id,
                $set:level:current_level-1
        else
            next_level = current_level + 1
            Docs.update doc_id,
                $set:
                    level:next_level
                    updated: Date.now()
            Meteor.call 'create_event', doc_id, 'escalate', "Automatic escalation from #{current_level} to #{next_level}."
            Meteor.call 'email_about_escalation', doc_id


    clear_incident_events: (incident_id)->
        cursor = Docs.find
            parent_id: incident_id
            type:'event'
        for event_doc in cursor.fetch()
            Docs.remove event_doc._id
            
            
    email_about_incident_submission: (incident_id)->
        incident = Docs.findOne incident_id
        customer = Docs.findOne {
            "ev.ID":incident.customer_jpid
            type:'customer'
        }
        franchisee = Docs.findOne {
            "ev.FRANCHISEE":customer.ev.FRANCHISEE
            type:'franchisee'
        }
            
        # console.log 'franchisee', franchisee 
        office_doc = Docs.findOne {
            "ev.MASTER_LICENSEE":incident.incident_office_name
            type:'office'
        }
        incident_owner_username = office_doc["#{incident.incident_type}_incident_owner"]
        initial_secondary_contact_value = office_doc["escalation_1_#{incident.incident_type}_secondary_contact"]
        
        initial_franchisee_value = office_doc["escalation_1_#{incident.incident_type}_contact_franchisee"]
        initial_customer_value = office_doc["escalation_1_#{incident.incident_type}_contact_customer"]
        # console.log 'initial_secondary_contact_value', initial_secondary_contact_value
        mail_fields = {
            to: ["richard@janhub.com <richard@janhub.com>","zack@janhub.com <zack@janhub.com>", "Nicholas.Rose@premiumfranchisebrands.com <Nicholas.Rose@premiumfranchisebrands.com>"]
            from: "Jan-Pro Customer Portal <portal@jan-pro.com>"
            subject: "Incident from #{incident.customer_name} submitted."
            text: ''
            html: "<h4>Incident from #{incident.customer_name} submitted by customer.</h4>
                <h5>Type: #{incident.incident_type}</h5>
                <h5>Number: #{incident.incident_number}</h5>
                <h5>Details: #{incident.incident_details}</h5>
                <h5>Timestamp: #{incident.timestamp}</h5>
                <h5>Office: #{incident.incident_office_name}</h5>
                <h5>Status: #{incident.status}</h5>
                <h5>Service Date: #{incident.service_date}</h5>
                <h4>This will notify</h4>
                <h5>Incident Owner: #{incident_owner_username}</h5>
                <h5>Secondary Office Contact: #{initial_secondary_contact_value}</h5>
                <h5>Franchisee: #{initial_franchisee_value}, #{franchisee.ev.FRANCHISEE} at #{franchisee.ev.FRANCH_EMAIL}</h5>
            "
        }
        Meteor.call 'create_event', incident_id, 'emailed_owner', "#{incident_owner_username} emailed as the incident owner after initial submission."
        Meteor.call 'create_event', incident_id, 'emailed_secondary_contact', "#{initial_secondary_contact_value} emailed as the secondary contact for initial submission."
        if initial_franchisee_value
            Meteor.call 'create_event', incident_id, 'emailed_franchisee_contact', "Franchisee #{franchisee.ev.FRANCHISEE} emailed after incident submission."

        Meteor.call 'send_email', mail_fields
    
    
    send_email_about_incident_assignment:(incident_doc_id, username)->
        incident_doc = Docs.findOne incident_doc_id
        
        assigned_to_user = Meteor.users.findOne username:username
        incident_link = "https://www.jan.meteorapp.com/view/#{incident_doc._id}"
        unnassign_self_link = "https://www.jan.meteorapp.com/view/#{incident_doc._id}?username=#{assigned_to_user.username}"
        
        mail_fields = {
            # to: ["richard@janhub.com <richard@janhub.com>","zack@janhub.com <zack@janhub.com>", "Nicholas.Rose@premiumfranchisebrands.com <Nicholas.Rose@premiumfranchisebrands.com>", "<#{assigned_to_user.emails[0].address}>"]
            to: ["richard@janhub.com <richard@janhub.com>","zack@janhub.com <zack@janhub.com>", "Nicholas.Rose@premiumfranchisebrands.com <Nicholas.Rose@premiumfranchisebrands.com>"]
            from: "Jan-Pro Customer Portal <portal@jan-pro.com>"
            subject: "#{assigned_to_user.username} Assigned to Incident"
            html: "<h4>#{assigned_to_user.username}, you have been assigned to incident ##{incident_doc.incident_number} from customer: #{incident_doc.customer_name}.</h4>
                <h5>Type: #{incident_doc.incident_type}</h5>
                <h5>Number: #{incident_doc.incident_number}</h5>
                <h5>Details: #{incident_doc.incident_details}</h5>
                <h5>Timestamp: #{incident_doc.timestamp}</h5>
                <h5>Office: #{incident_doc.incident_office_name}</h5>
                <h5>Open: #{incident_doc.open}</h5>
                <h5>Service Date: #{incident_doc.service_date}</h5>
                <p>View the incident <a href=#{incident_link}>here</a>.</p>
                <p>Mark task complete <a href=#{unnassign_self_link}>here</a>.</p>
            "
        }
        Meteor.call 'send_email', mail_fields

    
    email_about_escalation: (incident_id)->
        incident = Docs.findOne incident_id
        customer = Docs.findOne {
            "ev.ID":incident.customer_jpid
            type:'customer'
        }
        franchisee = Docs.findOne {
            "ev.FRANCHISEE":customer.ev.FRANCHISEE
            type:'franchisee'
        }
            
        # console.log 'franchisee', franchisee 
        office_doc = Docs.findOne {
            "ev.MASTER_LICENSEE":incident.incident_office_name
            type:'office'
        }
        # escalation_1_primary_contact_franchisee: true,
        incident_owner_username = office_doc["#{incident.incident_type}_incident_owner"]
        escalation_secondary_contact_value = office_doc["escalation_#{incident.level}_#{incident.incident_type}_secondary_contact"]
        
        escalation_franchisee_value = office_doc["escalation_#{incident.level}_#{incident.incident_type}_contact_franchisee"]
        escalation_customer_value = office_doc["escalation_#{incident.level}_#{incident.incident_type}_contact_customer"]
        
        # console.log escalation_franchisee_value
        
        # console.log "escalation_#{incident.level}_secondary_contact"
        # console.log 'incident_owner_username',incident_owner_username
        # console.log 'escalation_secondary_contact_value',escalation_secondary_contact_value
        mail_fields = {
            to: ["richard@janhub.com <richard@janhub.com>","zack@janhub.com <zack@janhub.com>", "Nicholas.Rose@premiumfranchisebrands.com <Nicholas.Rose@premiumfranchisebrands.com>"]
            from: "Jan-Pro Customer Portal <portal@jan-pro.com>"
            subject: "Incident from #{incident.customer_name} escalated to #{incident.level}."
            text: ''
            html: "<h4>Incident from #{incident.customer_name} escalated to #{incident.level}.</h4>
                <ul>
                    <li>Type: #{incident.incident_type}</li>
                    <li>Details: #{incident.incident_details}</li>
                    <li>Office: #{incident.incident_office_name}</li>
                    <li>Open: #{incident.open}</li>
                    <li>Submitted: #{incident.submitted}</li>
                    <li>Service Date: #{incident.service_date}</li>
                </ul>
                <h4>This will notify</h4>
                <ul>
                    <li>Incident Owner: #{incident_owner_username}</li>
                    <li>Secondary Office Contact: #{escalation_secondary_contact_value}</li>
                    <li>Franchisee: #{escalation_franchisee_value}, #{franchisee.ev.FRANCHISEE} at #{franchisee.ev.FRANCH_EMAIL}</li>
                </ul>
            "
        }
        
        Meteor.call 'send_message', incident_owner_username, 'system_escalation_bot', "You are being notified as the incident owner for a #{incident.incident_type} escalation to level #{incident.level} from #{incident.customer_name}."
        Meteor.call 'send_message', escalation_secondary_contact_value, 'system_escalation_bot', "You are being notified as secondary contact for a #{incident.incident_type} escalation to level #{incident.level} from #{incident.customer_name}."
        
        Meteor.call 'create_event', incident_id, 'emailed_primary_contact', "#{incident_owner_username} emailed as the incident owner for a #{incident.incident_type} escalation to level #{incident.level}."
        Meteor.call 'create_event', incident_id, 'emailed_secondary_contact', "#{escalation_secondary_contact_value} emailed as the secondary contact for a #{incident.incident_type} escalation to level #{incident.level}."
        if escalation_franchisee_value
            Meteor.call 'create_event', incident_id, 'emailed_franchisee_contact', "Franchisee #{franchisee.ev.FRANCHISEE} emailed for a #{incident.incident_type} escalation to level #{incident.level}."
            Meteor.call 'send_message', franchisee.ev.FRANCHISEE, 'system_escalation_bot', "You are being notified as the franchisee for a #{incident.incident_type} escalation to level #{incident.level} from #{incident.customer_name}."
        if escalation_customer_value
            Meteor.call 'create_event', incident_id, 'emailed_franchisee_contact', "Franchisee #{franchisee.ev.FRANCHISEE} emailed for a #{incident.incident_type} escalation to level #{incident.level}."
            Meteor.call 'send_message', incident.customer_name, 'system_escalation_bot', "You are being notified as the customer for an incident submission."

        Meteor.call 'send_email', mail_fields


    single_escalation_check: (incident_id)->
        incident = Docs.findOne incident_id
        if incident.level is 4
            return
            # Meteor.call 'create_event', incident_id, 'max_level_notice', "Incident is at max level 4, not escalating."
        else
            incident_office =
                Docs.findOne
                    "ev.MASTER_LICENSEE": incident.incident_office_name
                    type:'office'
            current_level = incident.level
            next_level = current_level + 1

            last_updated = incident.updated
            existing_hours_value = incident_office["escalation_#{next_level}_#{incident.incident_type}_hours"]
            if existing_hours_value 
                hours_value = existing_hours_value
            else 
                hours_value = 2
                Meteor.call 'create_event', incident_id, 'setting_default_escalation_time', "No escalation minutes found, using 2 as the default."
            
            now = Date.now()
            updated_now_difference = now-last_updated
            seconds_elapsed = Math.floor(updated_now_difference/1000)
            minutes_elapsed = Math.floor(seconds_elapsed/60)
            escalation_calculation = minutes_elapsed - hours_value
            if minutes_elapsed < hours_value
                Meteor.call 'create_event', incident_id, 'not-escalate', "#{minutes_elapsed} minutes have elapsed, less than #{hours_value} in the escalations level #{next_level} #{incident.incident_type} rules, not escalating."
                # continue
            else    
                Meteor.call 'create_event', incident_id, 'escalate', "#{minutes_elapsed} minutes have elapsed, more than #{hours_value} in the escalations level #{next_level} #{incident.incident_type} rules, escalating."
                Meteor.call 'escalate_incident', incident._id, ->
            
    escalate_incident: (doc_id)-> 
        incident = Docs.findOne doc_id
        current_level = incident.level
        if current_level > 3
            Docs.update doc_id,
                $set:level:current_level-1
        else
            next_level = current_level + 1
            Docs.update doc_id,
                $set:
                    level:next_level
                    updated: Date.now()
            Meteor.call 'create_event', doc_id, 'escalate', "Automatic escalation from #{current_level} to #{next_level}."
            Meteor.call 'email_about_escalation', doc_id


    clear_incident_events: (incident_id)->
        cursor = Docs.find
            parent_id: incident_id
            type:'event'
        for event_doc in cursor.fetch()
            Docs.remove event_doc._id
            
