Meteor.methods
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
            text: "#{Meteor.user().username} submitted ticket."
        Meteor.call 'notify_about_ticket_submission', ticket_id

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
                text:"Ticket owner #{sla.ticket_owner} assigned after submission."
            Docs.insert
                type:'event'
                event_type:'timestamp_update'
                parent_id:ticket_id
                text:"Assignment timestamp updated."


    complete_ticket_task: (ticket_id, username, completion_details)->
        removed_user = Meteor.users.findOne username:username
        ticket = Docs.findOne ticket_id
        Docs.update ticket_id,
            $pull: assigned_to: removed_user._id
            $set: assignment_timestamp:Date.now()
        Docs.insert
            type:'event'
            parent_id:ticket_id
            event_type:'unassignment'
            text: "#{username} completed task with note: #{completion_details}."
            ticket_id:ticket_id
            office_jpid:ticket.office_jpid
            customer_jpid: ticket.customer_jpid


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
            submitted:true,
            level: $lte:3
            })
        open_tickets_count = open_tickets.count()
        console.log open_tickets_count
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
        ticket_type = Docs.findOne
            type:'ticket_type'
            slug:ticket.ticket_type

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
        console.log 'updated_now_difference', updated_now_difference
        seconds_elapsed = Math.floor(updated_now_difference/1000)
        minutes_elapsed = Math.floor(seconds_elapsed/60)
        hours_elapsed = Number.parseFloat((seconds_elapsed/60/60)).toFixed(1)
        sla_minutes = hours_value*60
        escalation_calculation = minutes_elapsed - sla_minutes
        # escalation_calculation = hours_elapsed - hours_value


        console.log 'new calc'
        console.log 'minutes_elapsed', minutes_elapsed
        console.log 'sla_minutes', sla_minutes
        console.log 'hours elapsed', hours_elapsed
        console.log 'escalation calc', escalation_calculation

        if minutes_elapsed > sla_minutes
            Docs.insert
                type:'event'
                parent_id:ticket_id
                event_type:'escalate'
                office_jpid:ticket.office_jpid
                customer_jpid:ticket.customer_jpid
                level:next_level
                ticket_id:ticket_id
                text:"#{hours_elapsed} hours have elapsed, more than #{hours_value} in level #{next_level} '#{ticket_type.title}' rules, escalating."
            Meteor.call 'escalate_ticket', ticket._id, ->
            console.log 'ESCALATING', ticket._id
        else
            console.log 'not escalating', ticket_id


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
                office_jpid:ticket.office_jpid
                customer_jpid:ticket.customer_jpid
                level:next_level
                ticket_id:ticket_id


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
            type:'customer' }
        if ticket.franchisee_jpid
            franchisee = Docs.findOne {
                "ev.ID":ticket.franchisee_jpid
                type:'franchisee' }

        office_doc = Docs.findOne {
            "ev.ID":ticket.office_jpid
            type:'office' }

        ticket_type = Docs.findOne
            type:'ticket_type'
            slug:ticket.ticket_type


        sla =
            Docs.findOne
                type:'sla_setting'
                escalation_number:ticket.level
                ticket_type:ticket.ticket_type
                office_jpid:ticket.office_jpid

        mail_fields = {
            to: ["<richard@janhub.com>","<zack@janhub.com>", "<Nicholas.Rose@premiumfranchisebrands.com>","<brad@janhub.com>","<colin.bates@jan-pro.com>","<hendra.oey@jan-pro.com>"]
            from: "Jan-Pro Customer Portal <portal@jan-pro.com>"
            subject: "Ticket from #{ticket.customer_name} submitted."
            text: ''
            html: "<h4>Ticket from #{ticket.customer_name} submitted by customer.</h4>
                <ul>
                    <li>Type: #{ticket.ticket_type}</li>
                    <li>Number: #{ticket.ticket_number}</li>
                    <li>Details: #{ticket.ticket_details}</li>
                    <li>Timestamp: #{ticket.long_timestamp}</li>
                    <li>Office: #{ticket.ticket_office_name}</li>
                    <li>Open: #{ticket.open}</li>
                    <li>Service Date: #{ticket.service_date}</li>
                </ul>
                <h4>Owner: #{sla.ticket_owner}</h4>
                <p>SMS Owner: #{sla.sms_owner}</p>
                <p>Email Owner: #{sla.email_owner}</p>
                <h4>Secondary: #{sla.secondary_contact}</h4>
                <p>SMS Secondary: #{sla.sms_secondary}</p>
                <p>Email Secondary: #{sla.email_secondary}</p>
                <h4>Franchisee: #{franchisee.ev.FRANCHISEE} at #{franchisee.ev.FRANCH_EMAIL}</h4>
                <p> Email Franchisee: #{sla.contact_franchisee}</p>

                <h4>Customer: #{customer.ev.CUST_NAME} at email: #{customer.ev.CUST_CONTACT_EMAIL}</h4>
                <p> Email Customer: #{sla.contact_customer}</p>

            "
        }

                        # <h5>Franchisee: #{sla.contact_franchisee}, #{franchisee.ev.FRANCHISEE} at #{franchisee.ev.FRANCH_EMAIL}</h5>
        if sla.sms_owner
            Meteor.call 'send_sms', '+19176643297', "#{sla.ticket_owner}, a '#{ticket_type.title}' ticket from #{ticket.customer_name} was submitted."
            Docs.insert
                type:'event'
                parent_id:ticket_id
                recipient_username: sla.ticket_office
                event_type: 'sms_owner'
                text:"SMS sent to #{sla.ticket_owner} about #{ticket.customer_name} escalation to #{ticket.level}."
            Docs.insert
                type:'message'
                message_type:'sms'
                recipient_type:'owner'
                to: sla.ticket_owner
                body: "#{sla.ticket_owner}, you're being notified as the owner for a '#{ticket_type.title}' ticket submission."
                ticket_id: ticket_id

        if sla.email_owner
            Docs.insert
                type:'event'
                parent_id:ticket_id
                event_type:'email_owner'
                text:"Email sent to owner #{sla.ticket_owner} after ticket submission."
            Docs.insert
                type:'message'
                message_type:'email'
                recipient_type:'owner'
                to: sla.ticket_owner
                body: "#{sla.secondary_contact}, you're being notified as the owner for a '#{ticket_type.title}' ticket submission."
                ticket_id: ticket_id

        if sla.email_secondary
            Docs.insert
                type:'message'
                message_type:'email'
                recipient_type:'secondary'
                to: sla.secondary_contact
                body: "#{sla.secondary_contact}, you're being notified as the secondary contact for a '#{ticket_type.title}' ticket submission."
                ticket_id: ticket_id
            Docs.insert
                type:'event'
                parent_id:ticket_id
                event_type:'email_secondary'
                text:"Email sent to secondary contact #{sla.secondary_contact} after ticket submission."

        if sla.sms_secondary
            Meteor.call 'send_sms', '+19176643297', "#{sla.secondary_contact}, a '#{ticket_type.title}' ticket from #{ticket.customer_name} was submitted."
            Docs.insert
                type:'message'
                message_type:'sms'
                to: sla.secondary_contact
                recipient_type:'secondary'
                body: "#{sla.secondary_contact}, a '#{ticket_type.title}' ticket from #{ticket.customer_name} was submitted."
                ticket_id: ticket_id
            Docs.insert
                type:'event'
                parent_id:ticket_id
                event_type:'sms_secondary'
                text:"SMS sent to secondary contact #{sla.secondary_contact} for ticket submission."

        if sla.contact_franchisee
            if ticket.franchisee_jpid
                Docs.insert
                    type:'message'
                    message_type:'sms'
                    recipient_type:'franchisee'
                    to: sla.secondary_contact
                    body: "#{franchisee.ev.FRANCHISEE}, a '#{ticket_type.title}' ticket from #{ticket.customer_name} was submitted."
                    ticket_id: ticket_id
                Docs.insert
                    type:'event'
                    parent_id:ticket_id
                    event_type:'email_franchisee'
                    text:"Email sent to franchisee #{franchisee.ev.FRANCHISEE} after ticket submission."

        if sla.contact_customer
            Docs.insert
                type:'message'
                message_type:'sms'
                recipient_type:'customer'
                to: customer.ev.CUST_NAME
                body: "#{customer.ev.CUST_NAME}, your ticket ##{ticket.ticket_number} was submitted."
                ticket_id: ticket_id
            Docs.insert
                type:'event'
                parent_id:ticket_id
                event_type:'email_customer'
                text:"Email sent to customer #{customer.ev.CUST_NAME} after ticket submission."

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
            to: ["<richard@janhub.com>","<zack@janhub.com>", "<Nicholas.Rose@premiumfranchisebrands.com>","<brad@janhub.com>","<colin.bates@jan-pro.com>","<hendra.oey@jan-pro.com>"]
            from: "Jan-Pro Customer Portal <portal@jan-pro.com>"
            subject: "Ticket from #{ticket.customer_name} escalated to #{ticket.level}."
            text: ''
            html: "<h4>Ticket from #{ticket.customer_name} escalated to #{ticket.level}.</h4>
                <ul>
                    <li>##{ticket.ticket_number}</li>
                    <li>Type: #{ticket.ticket_type}</li>
                    <li>Created: #{ticket.long_timestamp}</li>
                    <li>Details: #{ticket.ticket_details}</li>
                    <li>Office: #{ticket.ticket_office_name}</li>
                    <li>Open: #{ticket.open}</li>
                    <li>Submitted: #{ticket.submitted}</li>
                    <li>Service Date: #{ticket.service_date}</li>
                </ul>
                <h4>Owner: #{sla.ticket_owner}</h4>
                <p>SMS Owner: #{sla.sms_owner}</p>
                <p>Email Owner: #{sla.email_owner}</p>
                <h4>Secondary: #{sla.secondary_contact}</h4>
                <p>SMS Secondary: #{sla.sms_secondary}</p>
                <p>Email Secondary: #{sla.email_secondary}</p>
                <h4>Franchisee: #{franchisee.ev.FRANCHISEE} at #{franchisee.ev.FRANCH_EMAIL}</h4>
                <p> Email Franchisee: #{sla.contact_franchisee}</p>

                <h4>Customer: #{customer.ev.CUST_NAME} at email: #{customer.ev.CUST_CONTACT_EMAIL}</h4>
                <p> Email Customer: #{sla.contact_customer}</p>

            "
        }

        ticket_type = Docs.findOne
            type:'ticket_type'
            slug:ticket.ticket_type



        if sla.sms_owner
            # Meteor.call 'send_sms', '+19176643297', "#{sla.ticket_owner}, your ticket from #{ticket.customer_name} escalated to #{ticket.level}."
            Docs.insert
                type:'event'
                parent_id:ticket_id
                recipient_username: sla.ticket_office
                event_type: 'sms_owner'
                text:"SMS sent to #{sla.ticket_owner} about #{ticket.customer_name} escalation to #{ticket.level}."
            Docs.insert
                type:'message'
                message_type:'sms'
                recipient_type:'owner'
                to: sla.ticket_owner
                body: "#{sla.ticket_owner}, a '#{ticket_type.title}' ticket from #{ticket.customer_name} escalated to #{ticket.level}."
                ticket_id: ticket_id


        if sla.email_owner
            Docs.insert
                type:'event'
                parent_id:ticket_id
                event_type:'email_owner'
                text:"#{sla.ticket_owner} emailed as the ticket owner for a '#{ticket_type.title}' escalation to level #{ticket.level}."
            Docs.insert
                type:'message'
                message_type:'email'
                recipient_type:'owner'
                to: sla.ticket_owner
                body: "#{sla.ticket_owner}, a '#{ticket_type.title}' ticket from #{ticket.customer_name} escalated to #{ticket.level}."
                ticket_id: ticket_id

        if sla.sms_secondary
            Meteor.call 'send_sms', '+19176643297', "#{sla.secondary_contact}, a '#{ticket_type.title}' ticket from #{ticket.customer_name} escalated to #{ticket.level}."
            Docs.insert
                type:'event'
                parent_id:ticket_id
                event_type:'sms_secondary'
                text:"SMS sent to #{sla.secondary_contact} for a '#{ticket_type.title}' escalation to level #{ticket.level}."
            Docs.insert
                type:'message'
                message_type:'sms'
                recipient_type:'secondary'
                to: sla.secondary_contact
                body: "#{sla.secondary_contact}, a '#{ticket_type.title}' ticket from #{ticket.customer_name} escalated to #{ticket.level}."
                ticket_id: ticket_id

        if sla.email_secondary
            Docs.insert
                type:'event'
                parent_id:ticket_id
                event_type: 'email_secondary'
                text: "SMS sent to #{sla.secondary_contact}, secondary contact for a '#{ticket_type.title}' escalation to level #{ticket.level}."
            Docs.insert
                type:'message'
                message_type:'email'
                recipient_type:'secondary'
                to: sla.secondary_contact
                body: "#{sla.secondary_contact}, a '#{ticket_type.title}' ticket from #{ticket.customer_name} escalated to #{ticket.level}."
                ticket_id: ticket_id

        if sla.contact_franchisee
            Docs.insert
                type:'event'
                parent_id:ticket_id
                event_type: 'email_franchisee'
                text: "Email sent to franchisee #{franchisee.ev.FRANCHISEE} for a '#{ticket_type.title}' escalation to level #{ticket.level}."
            Docs.insert
                type:'message'
                message_type:'email'
                recipient_type:'secondary'
                to: sla.secondary_contact
                body: "#{franchisee.ev.FRANCHISEE}, a '#{ticket_type.title}' ticket from #{ticket.customer_name} escalated to #{ticket.level}."
                ticket_id: ticket_id

        if sla.contact_customer
            Docs.insert
                type:'message'
                message_type:'email'
                recipient_type:'secondary'
                to: sla.secondary_contact
                body: "#{franchisee.ev.FRANCHISEE}, a '#{ticket_type.title}' ticket from #{ticket.customer_name} escalated to #{ticket.level}."
                ticket_id: ticket_id
            Docs.insert
                type:'event'
                parent_id:ticket_id
                event_type: 'email_customer'
                text:"#{customer.ev.CUST_NAME} a '#{ticket_type.title}' ticket escalated to level #{ticket.level}."

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
            return new_ticket_id