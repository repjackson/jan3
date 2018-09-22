Meteor.methods
    assign_ticket_owner_after_submission: (ticket_id)->
        ticket = Docs.findOne ticket_id
        sla = 
            Docs.findOne
                type:'sla_setting'
                escalation_number:1
                ticket_type:ticket.ticket_type
                office_jpid:ticket.office_jpid
        if sla.ticket_owner
            owner_user = Meteor.users.findOne username:sla.ticket_owner
            Docs.update ticket_id,
                $addToSet: assigned_to: owner_user._id
                $set: assignment_timestamp:Date.now()
            Docs.insert
                type:'event'
                event_type:'assignment'
                parent_id:ticket_id
                text:"Ticket owner #{sla.ticket_owner} automatically assigned after submission."
            Docs.insert
                type:'event'
                event_type:'timestamp_update'
                parent_id:ticket_id
                text:"Assignment timestamp updated."
    
    submit_ticket: (ticket_id)->
        ticket = Docs.findOne ticket_id
    
        sla = 
            Docs.findOne
                type:'sla_setting'
                escalation_number:1
                ticket_type:ticket.ticket_type
                office_jpid:ticket.office_jpid
                
        if sla.escalation_hours
            Docs.insert
                type:'event'
                parent_id:ticket_id
                event_type:'escalation_notice'
                text: "Ticket will escalate in #{sla.escalation_hours} hours according to #{ticket.ticket_office_name} initial rules."
        Docs.update ticket_id,
            $set:
                submitted:true
                submitted_datetime: Date.now()
                last_updated_datetime: Date.now()
        Meteor.call 'assign_ticket_owner_after_submission', ticket_id
        Docs.insert
            type:'event'
            parent_id:ticket_id
            event_type:'submit'
            text: "submitted the ticket."
        Meteor.call 'notify_about_ticket_submission', ticket_id

    
    unassign_user_from_ticket: (ticket_id, username)->
        removed_user = Meteor.users.findOne username:username
        ticket = Docs.findOne ticket_id
        Docs.update ticket_id,
            $pull: assigned_to: removed_user._id
            $set: assignment_timestamp:Date.now()
        Docs.insert
            type:'event'
            parent_id:ticket_id
            event_type:'unassignment'
            text: "#{username} marked task complete and was unassigned."
        # assign owner if no one else
        updated_doc = Docs.findOne ticket_id
        if updated_doc.assigned_to.length is 0
            ticket_office = Docs.findOne({
                type:'office' 
                "ev.ID":updated_doc.office_jpid
                })
            
            sla = 
                Docs.findOne
                    type:'sla_setting'
                    escalation_number:ticket.level
                    ticket_type:ticket.ticket_type
                    office_jpid:ticket.office_jpid

            
            owner_user = Meteor.users.findOne username:sla.ticket_owner
            Docs.update ticket_id, 
                $addToSet:assigned_to:owner_user._id
            Docs.insert
                type:'event'
                parent_id:ticket_id
                event_type:'assignment'
                text: "Owner #{sla.ticket_owner} reassigned after completed task by #{username}."
    
            
    run_site_escalation_check: ->
        open_tickets = Docs.find({
            type:'ticket', 
            open:true, 
            submitted:true
            level: $lte:3
            })
        open_tickets_count = open_tickets.count()
        Meteor.call 'create_event',null, 'start_escalation_check', "Starting esclation check."
        Meteor.call 'create_event',null, 'ticket_count', "Found #{open_tickets_count} open tickets, checking escalation status."
        for ticket in open_tickets.fetch()
            Meteor.call 'single_escalation_check', ticket._id
         
    single_escalation_check: (ticket_id)->
        ticket = Docs.findOne ticket_id
        current_level = ticket.level
        next_level = current_level + 1
        last_updated = ticket.updated

        sla = 
            Docs.findOne
                type:'sla_setting'
                escalation_number:next_level
                ticket_type:ticket.ticket_type
                office_jpid:ticket.office_jpid

        if sla.escalation_hours 
            hours_value = sla.escalation_hours
        else 
            hours_value = 2
            Docs.insert
                type:'event'
                parent_id: ticket_id
                event_type: 'setting_default_escalation_time'
                text: "No escalation hours found, using 2 as the default."
            
        now = Date.now()
        updated_now_difference = now-last_updated
        seconds_elapsed = Math.floor(updated_now_difference/1000)
        hours_elapsed = Math.floor(seconds_elapsed/60/60)
        escalation_calculation = hours_elapsed - hours_value
        
        ticket_type = Docs.findOne
            type:'ticket_type'
            slug:ticket.ticket_type
    
        if hours_elapsed < hours_value
            Docs.insert
                type:'event'
                parent_id:ticket_id
                event_type:'not-escalate'
                text: "#{hours_elapsed} hours have elapsed, less than #{hours_value} in level #{next_level} '#{ticket_type.title}' rules, not escalating."
        else    
            Docs.insert
                type:'event'
                parent_id:ticket_id
                event_type:'escalate'
                text:"#{hours_elapsed} hours have elapsed, more than #{hours_value} in level #{next_level} '#{ticket_type.title}' rules, escalating."
            Meteor.call 'escalate_ticket', ticket._id, ->
            
    escalate_ticket: (doc_id)-> 
        ticket = Docs.findOne doc_id
        current_level = ticket.level
        if current_level > 3
            Docs.update doc_id,
                $set:level:current_level-1
        else
            next_level = current_level + 1
            Docs.update doc_id,
                $set:
                    level:next_level
                    updated: Date.now()
            Docs.insert
                type:'event'
                parent_id:ticket_id
                event_type:'escalate'
                text:"Automatic escalation from #{current_level} to #{next_level}."

            
            Meteor.call 'notify_about_escalation', doc_id


    clear_ticket_events: (ticket_id)->
        cursor = Docs.find
            parent_id: ticket_id
            type:'event'
        for event_doc in cursor.fetch()
            Docs.remove event_doc._id
            
            
    notify_about_ticket_submission: (ticket_id)->
        ticket = Docs.findOne ticket_id
        
        customer = Docs.findOne {
            "ev.ID":ticket.customer_jpid
            type:'customer'
        }
        if ticket.franchisee_jpid
            franchisee = Docs.findOne {
                "ev.ID":ticket.franchisee_jpid
                type:'franchisee'
            }
            
        office_doc = Docs.findOne {
            "ev.ID":ticket.office_jpid
            type:'office'
        }
        
        
        sla = 
            Docs.findOne
                type:'sla_setting'
                escalation_number:ticket.level
                ticket_type:ticket.ticket_type
                office_jpid:ticket.office_jpid
        
        
        mail_fields = {
            to: ["richard@janhub.com <richard@janhub.com>","zack@janhub.com <zack@janhub.com>", "Nicholas.Rose@premiumfranchisebrands.com <Nicholas.Rose@premiumfranchisebrands.com>"]
            from: "Jan-Pro Customer Portal <portal@jan-pro.com>"
            subject: "Ticket from #{ticket.customer_name} submitted."
            text: ''
            html: "<h4>Ticket from #{ticket.customer_name} submitted by customer.</h4>
                <h5>Type: #{ticket.ticket_type}</h5>
                <h5>Number: #{ticket.ticket_number}</h5>
                <h5>Details: #{ticket.ticket_details}</h5>
                <h5>Timestamp: #{ticket.timestamp}</h5>
                <h5>Office: #{ticket.ticket_office_name}</h5>
                <h5>Status: #{ticket.status}</h5>
                <h5>Service Date: #{ticket.service_date}</h5>
                <h4>This will notify</h4>
                <h5>Ticket Owner: #{sla.ticket_owner}</h5>
                <h5>Secondary Office Contact: #{sla.secondary_contact}</h5>
                <h5>Franchisee: #{sla.contact_franchisee}, #{franchisee.ev.FRANCHISEE} at #{franchisee.ev.FRANCH_EMAIL}</h5>
                <h5>Customer: #{sla.contact_customer}, #{customer.ev.CUST_NAME} at #{customer.ev.CUST_CONTACT_EMAIL}</h5>
            "
        }
        Docs.insert
            type:'event'
            parent_id:ticket_id
            event_type:'emailed_owner'
            text:"#{sla.ticket_owner} emailed as the ticket owner after initial submission."
        Docs.insert
            type:'event'
            parent_id:ticket_id
            event_type:'emailed_secondary_contact'
            text:"#{sla.secondary_contact} emailed as the secondary contact for initial submission."
        if sla.sms_owner
            Meteor.call 'send_sms', '+19176643297', "#{sla.ticket_owner}, one of your tickets from #{ticket.customer_name} escalated to #{ticket.level}." 
        if sla.contact_franchisee
            Docs.insert
                type:'event'
                parent_id:ticket_id
                event_type:'emailed_franchisee_contact'
                text:"Franchisee #{franchisee.ev.FRANCHISEE} emailed after ticket submission."
        if sla.contact_customer
            Docs.insert
                type:'event'
                parent_id:ticket_id
                event_type:'emailed_customer_contact'
                text:"Customer #{customer.ev.CUST_NAME} emailed after ticket submission."
        
        Meteor.call 'send_email', mail_fields
    
    

    
    notify_about_escalation: (ticket_id)->
        ticket = Docs.findOne ticket_id
        
        customer = Docs.findOne {
            "ev.ID":ticket.customer_jpid
            type:'customer'
        }
        if ticket.franchisee_jpid
            franchisee = Docs.findOne {
                "ev.ID":ticket.franchisee_jpid
                type:'franchisee'
            }
            
        office_doc = Docs.findOne {
            "ev.ID":ticket.office_jpid
            type:'office'
        }

        sla = 
            Docs.findOne
                type:'sla_setting'
                escalation_number:ticket.level
                ticket_type:ticket.ticket_type
                office_jpid:ticket.office_jpid


        owner = Meteor.users.findOne username: sla.ticket_owner

        mail_fields = {
            to: ["richard@janhub.com <richard@janhub.com>","zack@janhub.com <zack@janhub.com>", "Nicholas.Rose@premiumfranchisebrands.com <Nicholas.Rose@premiumfranchisebrands.com>"]
            from: "Jan-Pro Customer Portal <portal@jan-pro.com>"
            subject: "Ticket from #{ticket.customer_name} escalated to #{ticket.level}."
            text: ''
            html: "<h4>Ticket from #{ticket.customer_name} escalated to #{ticket.level}.</h4>
                <ul>
                    <li>Type: #{ticket.ticket_type}</li>
                    <li>Details: #{ticket.ticket_details}</li>
                    <li>Office: #{ticket.ticket_office_name}</li>
                    <li>Open: #{ticket.open}</li>
                    <li>Submitted: #{ticket.submitted}</li>
                    <li>Service Date: #{ticket.service_date}</li>
                </ul>
                <h4>This will notify</h4>
                <ul>
                    <li>Ticket Owner: #{sla.ticket_owner}</li>
                    <li>Secondary Office Contact: #{sla.secondary_contact}</li>
                    <li>Franchisee: #{sla.contact_franchisee}, #{franchisee.ev.FRANCHISEE} at #{franchisee.ev.FRANCH_EMAIL}</li>
                </ul>
            "
        }
        
        ticket_type = Docs.findOne
            type:'ticket_type'
            slug:ticket.ticket_type
        
        
        Meteor.call 'send_message', sla.ticket_owner, 'system_escalation_bot', "You are being notified as the ticket owner for a '#{ticket_type.title}' escalation to level #{ticket.level} from #{ticket.customer_name}."
        Meteor.call 'send_message', sla.secondary_contact, 'system_escalation_bot', "You are being notified as secondary contact for a '#{ticket_type.title}' escalation to level #{ticket.level} from #{ticket.customer_name}."
        
        if sla.sms_owner
            Meteor.call 'send_sms', '+19176643297', "#{sla.ticket_owner}, one of your tickets from #{ticket.customer_name} escalated to #{ticket.level}." 
            Docs.insert
                type:'event'
                parent_id:ticket_id
                recipient_username: sla.ticket_office 
                text:"SMS sent to #{sla.ticket_owner} about #{ticket.customer_name} escalation to #{ticket.level}."
        
        if sla.email_owner
            Meteor.call 'create_event', ticket_id, 'emailed_ticket_owner', "#{sla.ticket_owner} emailed as the ticket owner for a '#{ticket_type.title}' escalation to level #{ticket.level}."
        if sla.sms_secondary
            Meteor.call 'create_event', ticket_id, 'emailed_franchisee_contact', "Franchisee #{franchisee.ev.FRANCHISEE} emailed for a '#{ticket_type.title}' escalation to level #{ticket.level}."
            Meteor.call 'send_sms', '+19176643297', "#{sla.secondary_contact}, one of your tickets from #{ticket.customer_name} escalated to #{ticket.level}." 
        if sla.email_secondary
            Docs.insert
                type:'event'
                parent_id:ticket_id
                event_type: 'emailed_secondary_contact'
                text: "#{sla.secondary_contact} emailed as the secondary contact for a '#{ticket_type.title}' escalation to level #{ticket.level}."
                
        
        if sla.contact_franchisee
            Meteor.call 'create_event', ticket_id, 'emailed_franchisee_contact', "Franchisee #{franchisee.ev.FRANCHISEE} emailed for a '#{ticket_type.title}' escalation to level #{ticket.level}."
            Meteor.call 'send_message', franchisee.ev.FRANCHISEE, 'system_escalation_bot', "You are being notified as the franchisee for a '#{ticket_type.title}' escalation to level #{ticket.level} from #{ticket.customer_name}."
        if sla.contact_customer
            Meteor.call 'create_event', ticket_id, 'emailed_franchisee_contact', "Franchisee #{franchisee.ev.FRANCHISEE} emailed for a '#{ticket_type.title}' escalation to level #{ticket.level}."
            Meteor.call 'send_message', ticket.customer_name, 'system_escalation_bot', "You are being notified as the customer for an ticket submission."

        Meteor.call 'send_email', mail_fields


    escalate_ticket: (ticket_id)-> 
        ticket = Docs.findOne ticket_id
        current_level = ticket.level
        if current_level > 3
            Docs.update ticket_id,
                $set:level:current_level-1
        else
            next_level = current_level + 1
            Docs.update ticket_id,
                $set:
                    level:next_level
                    updated: Date.now()
            Docs.insert
                type:'event'
                event_type:'escalate'
                parent_id:ticket_id
                text:"Automatic escalation from #{current_level} to #{next_level}."
                
            Meteor.call 'notify_about_escalation', ticket_id


    clear_ticket_events: (ticket_id)->
        cursor = Docs.find
            parent_id: ticket_id
            type:'event'
        for event_doc in cursor.fetch()
            Docs.remove event_doc._id
            

    log_ticket: ()->
        console.log 'hi'
        my_customer_ob = Meteor.user().users_customer()
        user = Meteor.user()
        if my_customer_ob
            ticket_count = Docs.find(type:'ticket').count()
            next_ticket_number = ticket_count + 1
            new_ticket_id = 
                Docs.insert
                    type: 'ticket'
                    ticket_number: next_ticket_number
                    franchisee_jpid: user.franchisee_jpid
                    office_jpid: user.office_jpid
                    customer_jpid: user.customer_jpid
                    customer_name: my_customer_ob.ev.CUST_NAME
                    ticket_office_name: my_customer_ob.ev.MASTER_LICENSEE
                    ticket_franchisee: my_customer_ob.ev.FRANCHISEE
                    level: 1
                    open: true
                    submitted: false
            console.log new_ticket_id
            return new_ticket_id