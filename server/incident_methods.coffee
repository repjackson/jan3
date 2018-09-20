Incident_Helpers = 
    generate_event: (event_type, incident_doc_id, action, author_id, timestamp) ->
        author_id = author_id or Meteor.userId()
        updated = Date.now();
        
        event = 
            type:'event'
            parent_id: incident_doc_id
            event_type: event_type
            action: action
            author_id: author_id
            updated: updated
        
        if timestamp
            #XXX refactor this (similar code in lib.coffee)
            event.timestamp = timestamp
            now = moment(timestamp)
            event.long_timestamp = now.format("dddd, MMMM Do YYYY, h:mm:ss a")
                
        return event
            
    email_someone: (type, name, email, incident_doc_id, incident_office_name, incident_level, save) -> 
        incident = Docs.findOne incident_doc_id

        
        incident_level_name = if incident_level == 1 then 'intial' else 'level #{incident_level} notifications'

        if type is 'owner'
            user_type = 'owner'
            event_type: 'emailed_incident_owner'
        else
            user_type = 'secondary contact'
            event_type: 'emailed_secondary_contact'
        
        #TODO: send email
        
        #save the event if asked to
        event_action = "Incident #{user_type} #{incident.incident_owner} has been emailed per #{incident.incident_office_name} #{incident_level_name} rules."
        
        if save
            Docs.insert
                type:'event'
                parent_id: incident_doc_id
                event_type: event_type
                action: event_action
        
        return @generate_event event_type, incident_doc_id, event_action, author_id, timestamp
        
    text_someone: (type, name, phone_number, incident_doc_id, incident_office_name, incident_level, save) -> 
        incident = Docs.findOne incident_doc_id
        incident_level_name = incident_level == 1 ? 'intial' : "level #{incident_level} notifications"
        
        if type is 'owner'
            user_type = 'owner'
            event_type: 'texted_incident_owner'
        else
            user_type = 'secondary contact'
            event_type: 'texted_secondary_contact'
        
        #TODO: send text
        
        
        
        
        #save the event if asked to
        event_action = "Incident #{user_type} #{incident.incident_owner} has been texted per #{incident.incident_office_name} #{incident_level_name} rules."
        
        if save
            Docs.insert
                type:'event'
                parent_id: incident_doc_id
                event_type: event_type
                action: event_action
        
        return @generate_event event_type, incident_doc_id, event_action, author_id, timestamp
        
    email_owner: (owner_name, owner_email, incident_doc_id, incident_office_name, incident_level, save) -> 
        return @email_someone 'owner', owner_name, owner_email, incident_doc_id, incident_office_name, incident_level, save
        
    text_owner: (owner_name, owner_phone, incident_doc_id, incident_office_name, incident_level, save) -> 
        return @text_someone 'owner', owner_name, owner_phone, incident_doc_id, incident_office_name, incident_level, save
        
    email_secondary: (secondary_name, secondary_email, incident_doc_id, incident_office_name, incident_level, save) -> 
        return @email_someone 'secondary', secondary_name, secondary_email, incident_doc_id, incident_office_name, incident_level, save
        
    text_secondary: (secondary_name, secondary_phone, incident_doc_id, incident_office_name, incident_level, save) -> 
        return @text_someone 'secondary', secondary_name, secondary_phone, incident_doc_id, incident_office_name, incident_level, save
    


Meteor.methods
    submit_incident: (incident_doc_id)->
        incident = Docs.findOne incident_doc_id
        
        console.log(JSON.stringify(incident, null, 4))
        
        sla = 
            Docs.findOne
                type:'sla_setting'
                escalation_number:1
                incident_type:incident.incident_type
                office_jpid:incident.office_jpid
                
        console.log(JSON.stringify(sla, null, 4))
        
        user = Meteor.user();
        
        events = [
            Incident_Helpers.generate_event 'submit', incident_doc_id, "#{user.username} submitted the incident.", user._id, Date.now()
        ]
                
        if sla
            #do what needed for owner
            if sla.email_owner or sla.sms_owner
                #get owner details
                owner = Meteor.users.findOne username:sla.incident_owner
                
                if sla.email_owner
                    events.push Incident_Helpers.email_owner sla.incident_owner, owner.ev.EMAIL, incident_doc_id, incident.incident_office_name, incident.incident_level, false
                
                if sla.sms_owner
                    events.push Incident_Helpers.text_owner sla.incident_owner, owner.phone, incident_doc_id, incident.incident_office_name, incident.incident_level, false
            
            #do what needed for secondary contact
            if sla.email_secondary or sla.sms_secondary
                #get owner details
                secondary = Meteor.users.findOne username:sla.secondary_contact
                
                if sla.email_secondary
                    events.push Incident_Helpers.email_secondary sla.secondary_contact, secondary.EV.EMAIL, incident_doc_id, incident.incident_office_name, incident.incident_level, false
                
                if sla.sms_secondary
                    events.push Incident_Helpers.text_secondary sla.secondary_contact, secondary.phone, incident_doc_id, incident.incident_office_name, incident.incident_level, false
            
            #do what needed for customer
            
            
            #do what needed for franchisee
            
            
            if sla.escalation_hours
                Meteor.call 'create_event', incident_doc_id, 'submit', "Incident will escalate in #{sla.escalation_hours} hours according to #{incident.incident_office_name} initial rules."

        
        Docs.update incident_doc_id,
            $set:
                submitted:true
                submitted_datetime: Date.now()
                last_updated_datetime: Date.now()
        Meteor.call 'assign_incident_owner_after_submission', incident_doc_id

        

        Meteor.call 'notify_about_incident_submission', incident_doc_id
    
    
    assign_incident_owner_after_submission: (incident_doc_id)->
        incident = Docs.findOne incident_doc_id
        sla = 
            Docs.findOne
                type:'sla_setting'
                escalation_number:1
                incident_type:incident.incident_type
                office_jpid:incident.office_jpid
        if sla.incident_owner
            owner_user = Meteor.users.findOne username:sla.incident_owner
            Docs.update incident_doc_id,
                $addToSet: assigned_to: owner_user._id
                $set: assignment_timestamp:Date.now()
            # escalation_hours = incidents_office["escalation_1_#{incident.incident_type}_hours"]
            Meteor.call 'create_event', incident_doc_id, 'assignment', "Incident owner #{sla.incident_owner} automatically assigned after submission."
            Meteor.call 'create_event', incident_doc_id, 'timestamp_update', "Assignment timestamp updated."
        # else
        #     throw new Meteor.Error 'no incident office found, cant run escalation rules'

    
    unassign_user_from_incident: (incident_doc_id, username)->
        removed_user = Meteor.users.findOne username:username
        incident = Docs.findOne incident_doc_id
        Docs.update incident_doc_id,
            $pull: assigned_to: removed_user._id
            $set: assignment_timestamp:Date.now()
        Docs.insert
            type:'event'
            parent_id: incident_doc_id
            event_type: 'unassignment'
            action: "#{username} marked task complete and was unassigned."

        # assign owner if no one else
        updated_doc = Docs.findOne incident_doc_id
        if updated_doc.assigned_to.length is 0
            incident_office = Docs.findOne({type:'office', "ev.ID":updated_doc.office_jpid})
            
            sla = 
                Docs.findOne
                    type:'sla_setting'
                    escalation_number:incident.level
                    incident_type:incident.incident_type
                    office_jpid:incident.office_jpid

            
            owner_user = Meteor.users.findOne username:sla.incident_owner
            Docs.update incident_doc_id, 
                $addToSet:assigned_to:owner_user._id
            Meteor.call 'create_event', incident_doc_id, 'assignment', "Owner #{sla.incident_owner} reassigned after completed task by #{username}."
                
            
    update_escalation_statuses: ->
        open_incidents = Docs.find({type:'incident', open:true, submitted:true})
        open_incidents_count = open_incidents.count()
        Meteor.call 'create_event',null, 'start_escalation_check', "Starting esclation check."
        Meteor.call 'create_event',null, 'incident_count', "Found #{open_incidents_count} open incidents, checking escalation status."
        for incident in open_incidents.fetch()
            Meteor.call 'single_escalation_check', incident._id
         
    single_escalation_check: (incident_doc_id)->
        incident = Docs.findOne incident_doc_id
        if incident.level is 4
            throw new Meteor.Error 'max_level_notice', "Incident is at max level 4, not escalating."
        else
            incident_office =
                Docs.findOne
                    "ev.MASTER_LICENSEE": incident.incident_office_name
                    type:'office'
            current_level = incident.level
            next_level = current_level + 1
            last_updated = incident.updated

            sla = 
                Docs.findOne
                    type:'sla_setting'
                    escalation_number:next_level
                    incident_type:incident.incident_type
                    office_jpid:incident.office_jpid

            if sla.escalation_hours 
                hours_value = sla.escalation_hours
            else 
                hours_value = 2
                Meteor.call 'create_event', incident_doc_id, 'setting_default_escalation_time', "No escalation hours found, using 2 as the default."
                
            now = Date.now()
            updated_now_difference = now-last_updated
            seconds_elapsed = Math.floor(updated_now_difference/1000)
            hours_elapsed = Math.floor(seconds_elapsed/60/60)
            escalation_calculation = hours_elapsed - hours_value
            
            incident_type_doc = Docs.findOne
                type:'incident_type'
                slug:incident.incident_type
        
            if hours_elapsed < hours_value
                Meteor.call 'create_event', incident_doc_id, 'not-escalate', "#{hours_elapsed} hours have elapsed, less than #{hours_value} in level #{next_level} '#{incident_type_doc.title}' rules, not escalating."
                # continue
            else    
                Meteor.call 'create_event', incident_doc_id, 'escalate', "#{hours_elapsed} hours have elapsed, more than #{hours_value} in level #{next_level} '#{incident_type_doc.title}' rules, escalating."
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


    clear_incident_events: (incident_doc_id)->
        cursor = Docs.find
            parent_id: incident_doc_id
            type:'event'
        for event_doc in cursor.fetch()
            Docs.remove event_doc._id
            
            
    notify_about_incident_submission: (incident_doc_id)->
        incident = Docs.findOne incident_doc_id
        
        customer = Docs.findOne {
            "ev.ID":incident.customer_jpid
            type:'customer'
        }
        if incident.franchisee_jpid
            franchisee = Docs.findOne {
                "ev.ID":incident.franchisee_jpid
                type:'franchisee'
            }
            
        office_doc = Docs.findOne {
            "ev.ID":incident.office_jpid
            type:'office'
        }
        
        
        sla = 
            Docs.findOne
                type:'sla_setting'
                escalation_number:incident.level
                incident_type:incident.incident_type
                office_jpid:incident.office_jpid
        
        
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
                <h5>Open: #{incident.open}</h5>
                <h5>Service Date: #{incident.service_date}</h5>
                <h4>This will notify</h4>
                <h5>Incident Owner: #{sla.incident_owner}</h5>
                <h5>Secondary Office Contact: #{sla.secondary_contact}</h5>
                <h5>Franchisee: #{sla.contact_franchisee}, #{franchisee.ev.FRANCHISEE} at #{franchisee.ev.FRANCH_EMAIL}</h5>
                <h5>Customer: #{sla.contact_customer}, #{customer.ev.CUST_NAME} at #{customer.ev.CUST_CONTACT_EMAIL}</h5>
            "
        }
        
        if sla.email_secondary
            Meteor.call 'create_event', incident_doc_id, 'emailed_secondary_contact', "#{sla.secondary_contact} emailed as the secondary contact for initial submission."
        if sla.email_owner
            Meteor.call 'create_event', incident_doc_id, 'emailed_owner', "#{sla.incident_owner} emailed as the incident owner after initial submission."
        if sla.sms_owner
            Meteor.call 'send_sms', '+19176643297', "#{sla.incident_owner}, one of your incidents from #{incident.customer_name} escalated to #{incident.level}." 
        if sla.contact_franchisee
            Meteor.call 'create_event', incident_doc_id, 'emailed_franchisee_contact', "Franchisee #{franchisee.ev.FRANCHISEE} emailed after incident submission."
        if sla.contact_customer
            Meteor.call 'create_event', incident_doc_id, 'emailed_customer_contact', "Customer #{customer.ev.CUST_NAME} emailed after incident submission."

        Meteor.call 'send_email', mail_fields
    
    

    
    email_about_escalation: (incident_doc_id)->
        incident = Docs.findOne incident_doc_id
        
        customer = Docs.findOne {
            "ev.ID":incident.customer_jpid
            type:'customer'
        }
        if incident.franchisee_jpid
            franchisee = Docs.findOne {
                "ev.ID":incident.franchisee_jpid
                type:'franchisee'
            }
            
        office_doc = Docs.findOne {
            "ev.ID":incident.office_jpid
            type:'office'
        }

        sla = 
            Docs.findOne
                type:'sla_setting'
                escalation_number:incident.level
                incident_type:incident.incident_type
                office_jpid:incident.office_jpid


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
                    <li>Incident Owner: #{sla.incident_owner}</li>
                    <li>Secondary Office Contact: #{sla.secondary_contact}</li>
                    <li>Franchisee: #{sla.contact_franchisee}, #{franchisee.ev.FRANCHISEE} at #{franchisee.ev.FRANCH_EMAIL}</li>
                </ul>
            "
        }
        
        incident_type_doc = Docs.findOne
            type:'incident_type'
            slug:incident.incident_type
        
        
        Meteor.call 'send_message', sla.incident_owner, 'system_escalation_bot', "You are being notified as the incident owner for a '#{incident_type_doc.title}' escalation to level #{incident.level} from #{incident.customer_name}."
        Meteor.call 'send_message', sla.secondary_contact, 'system_escalation_bot', "You are being notified as secondary contact for a '#{incident_type_doc.title}' escalation to level #{incident.level} from #{incident.customer_name}."
        
        if sla.sms_owner
            Meteor.call 'send_sms', '+19176643297', "#{sla.incident_owner}, one of your incidents from #{incident.customer_name} escalated to #{incident.level}." 
        # if sla.email_owner
        Meteor.call 'create_event', incident_doc_id, 'emailed_incident_owner', "#{sla.incident_owner} emailed as the incident owner for a '#{incident_type_doc.title}' escalation to level #{incident.level}."
        
        # new_event_id = 
        #     Docs.insert 
        #         type:'event'
        #         parent_id:incident_doc_id
        
        if sla.sms_secondary
            Meteor.call 'create_event', incident_doc_id, 'emailed_franchisee_contact', "Franchisee #{franchisee.ev.FRANCHISEE} emailed for a '#{incident_type_doc.title}' escalation to level #{incident.level}."
            Meteor.call 'send_sms', '+19176643297', "#{sla.secondary_contact}, one of your incidents from #{incident.customer_name} escalated to #{incident.level}." 
        if sla.email_secondary
            Meteor.call 'create_event', incident_doc_id, 'emailed_secondary_contact', "#{sla.secondary_contact} emailed as the secondary contact for a '#{incident_type_doc.title}' escalation to level #{incident.level}."
        if sla.sms_owner
            Meteor.call 'send_sms', '+19176643297', "#{sla.incident_owner}, one of your incidents from #{incident.customer_name} escalated to #{incident.level}." 

        
        if sla.contact_franchisee
            Meteor.call 'create_event', incident_doc_id, 'emailed_franchisee_contact', "Franchisee #{franchisee.ev.FRANCHISEE} emailed for a '#{incident_type_doc.title}' escalation to level #{incident.level}."
            Meteor.call 'send_message', franchisee.ev.FRANCHISEE, 'system_escalation_bot', "You are being notified as the franchisee for a '#{incident_type_doc.title}' escalation to level #{incident.level} from #{incident.customer_name}."
        if sla.contact_customer
            Meteor.call 'create_event', incident_doc_id, 'emailed_franchisee_contact', "Franchisee #{franchisee.ev.FRANCHISEE} emailed for a '#{incident_type_doc.title}' escalation to level #{incident.level}."
            Meteor.call 'send_message', incident.customer_name, 'system_escalation_bot', "You are being notified as the customer for an incident submission."

        Meteor.call 'send_email', mail_fields


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


    clear_incident_events: (incident_doc_id)->
        cursor = Docs.find
            parent_id: incident_doc_id
            type:'event'
        for event_doc in cursor.fetch()
            Docs.remove event_doc._id
            

    log_ticket: ()->
        my_customer_ob = Meteor.user().users_customer()
        user = Meteor.user()
        if my_customer_ob
            incident_count = Docs.find(type:'incident').count()
            if incident_count
                next_incident_number = incident_count + 1
                new_incident_doc_id = 
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
                return new_incident_doc_id
