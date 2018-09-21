api_key = Meteor.settings.mailgun.api_key
domain = Meteor.settings.mailgun.domain
mailgun = require('mailgun-js')({apiKey: api_key, domain: domain})

Twilio = require 'twilio'
twilio = Twilio(Meteor.settings.private.sms.sid, Meteor.settings.private.sms.token)
{ parse, format } = require 'libphonenumber-js'

@Incident_Helpers =
    generate_event: (event_type, incident_doc_id, action, author_id, timestamp) ->
        author_id = author_id or Meteor.userId()
        updated = Date.now();

        event =
            _id: Random.id()
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

    email_someone: (type, name, email, incident, save) ->
        incident_level_name = ''
        emailHtmlStart = ''
        emailSubject = ''
        if incident.level is 1
            incident_level_name = 'initial'
            emailHtmlStart = "<h4>Incident from #{incident.customer_name} submitted by customer.</h4>"
            emailSubject = "Incident from #{incident.customer_name} submitted."
        else
            emailHtmlStart = "<h4>Incident from #{incident.customer_name} escalated to level #{incident.level}.</h4>"
            incident_level_name = "level #{incident.level} notifications"
            emailSubject = "Incident from #{incident.customer_name} escalated to level #{incident.level}."


        emailHtmlEnd = "<h5>Type: #{incident.incident_type}</h5>
            <h5>Number: #{incident.incident_number}</h5>
            <h5>Details: #{incident.incident_details}</h5>
            <h5>Timestamp: #{incident.long_timestamp}</h5>
            <h5>Office: #{incident.incident_office_name}</h5>
            <h5>Open: #{incident.open}</h5>
            <h5>Service Date: #{incident.service_date}</h5>
        "


        user_type = null
        event_type = null

        if type is 'owner'
            user_type = 'owner'
            event_type = 'emailed_incident_owner'
        else if type is 'secondary'
            user_type = 'secondary contact'
            event_type = 'emailed_secondary_contact'
        else if type is 'customer'
            user_type = 'customer'
            event_type = 'emailed_customer_owner'
            emailSubject = 'Your incident has been submitted'
            emailHtmlStart = 'We have received your incident'
        else #must be a franchisee
            user_type = 'franchisee'
            event_type = 'emailed_incident_franchisee'

        if Meteor.isDevelopment and Meteor.settings.test
            console.log 'real email is: ' + email
            email = "#{Meteor.settings.test.gmailUsername}+#{type}@gmail.com"

        #send email
        mail_fields = {
            to: "#{name} <#{email}>"
            from: "Jan-Pro Customer Portal <portal@jan-pro.com>"
            subject: emailSubject
            text: ''
            html: emailHtmlStart + emailHtmlEnd
        }
        console.log mail_fields

        # mailgun.messages().send(mail_fields).catch (error) ->
        #     console.error error
        #     return

        #save the event if asked to
        event_action = "Incident #{user_type} #{name} has been emailed per #{incident.incident_office_name} #{incident_level_name} rules."

        if save
            Docs.insert
                type:'event'
                parent_id: incident._id
                event_type: event_type
                action: event_action

        return @generate_event event_type, incident._id, event_action, '', Date.now()

    text_someone: (type, name, phone_number, incident_doc_id, incident_office_name, incident_level, save) ->
        try
            phone_number format(parse(phone_number, {country: {default: 'US'}}), 'International_plaintext');
        catch err
            console.error "#{phone_number} is incorrect format"

            if Meteor.isProduction
                return

        incident_level_name = ""
        body = ""
        if incident_level == 1
            incident_level_name = "initial"
            body = "#{name}, A new ticket has been submitted"
        else
            body = "#{name}, An ticket has been escalated to level #{incident_level}";
            incident_level_name = "level #{incident_level} notifications"

        user_type = 'owner'
        event_type = 'emailed_incident_owner'
        if type is 'owner'
            user_type = 'owner'
            event_type: 'texted_incident_owner'
        else
            user_type = 'secondary contact'
            event_type: 'texted_secondary_contact'


        if Meteor.isDevelopment and Meteor.settings.test
            phone_number = Meteor.settings.test.phoneNumber

        #send text
        twilio.messages.create({
            to: phone_number,
            from: '+18442525977' #XXX put this in settings
            body: body
        }, (err,res)->
            if err
                console.error error
        )

        #save the event if asked to
        event_action = "Ticket #{user_type} #{name} has been texted per #{incident_office_name} #{incident_level_name} rules."

        if save
            Docs.insert
                type:'event'
                parent_id: incident_doc_id
                event_type: event_type
                action: event_action

        return @generate_event event_type, incident_doc_id, event_action, '', Date.now()

    email_owner: (owner_name, owner_email, incident, save) ->
        return @email_someone 'owner', owner_name, owner_email, incident, save

    text_owner: (owner_name, owner_phone, incident_doc_id, incident_office_name, incident_level, save) ->
        return @text_someone 'owner', owner_name, owner_phone, incident_doc_id, incident_office_name, incident_level, save

    email_secondary: (secondary_name, secondary_email, incident, save) ->
        return @email_someone 'secondary', secondary_name, secondary_email, incident, save

    text_secondary: (secondary_name, secondary_phone, incident_doc_id, incident_office_name, incident_level, save) ->
        return @text_someone 'secondary', secondary_name, secondary_phone, incident_doc_id, incident_office_name, incident_level, save

    email_customer: (customer_name, customer_email, incident, save) ->
        return @email_someone 'customer', customer_name, customer_email, incident, save

    email_franchisee: (franchisee_name, franchisee_email, incident, save) ->
        return @email_someone 'franchisee', franchisee_name, franchisee_email, incident, save

    handle_sla: (user_id, incident, escalation_number, mongoBulkOperation) ->
        incident_doc_id = incident._id

        if incident.franchisee_jpid
            franchisee = Docs.findOne {
                'ev.ID': incident.franchisee_jpid
                type: 'franchisee'
            }

        sla = Docs.findOne { 
            type:'sla_setting'
            escalation_number: escalation_number
            incident_type:incident.incident_type
            office_jpid:incident.office_jpid
        }

        user_id = user_id or Meteor.userId()
        customer = null

        secondary = Meteor.users.findOne username: sla.secondary_contact
        owner = Meteor.users.findOne username: sla.incident_owner
        # primary = Meteor.users.findOne username: sla.primary_contact

        console.log secondary
        console.log owner

        if sla
            if sla.email_owner or sla.sms_owner
                if sla.email_owner
                    owner_email = if owner.ev then owner.ev.EMAIL else ''
                    mongoBulkOperation.insert Incident_Helpers.email_owner sla.incident_owner, owner_email, incident, false

                if sla.sms_owner
                    mongoBulkOperation.insert Incident_Helpers.text_owner sla.incident_owner, owner.phone, incident_doc_id, incident.incident_office_name, incident.level, false

            if sla.email_secondary or sla.sms_secondary
                if sla.email_secondary
                    secondary_email = if secondary.ev then secondary.ev.EMAIL else ''
                    mongoBulkOperation.insert Incident_Helpers.email_secondary sla.secondary_contact, secondary_email, incident, false

                if sla.sms_secondary
                    mongoBulkOperation.insert Incident_Helpers.text_secondary sla.secondary_contact, secondary.phone, incident_doc_id, incident.incident_office_name, incident.level, false

            if sla.contact_customer
                customer_email = if customer.ev then customer.ev.EMAIL else ''
                mongoBulkOperation.insert Incident_Helpers.email_customer customer.username, customer_email, incident, false

            if sla.contact_franchisee and franchisee and franchisee.ev
                mongoBulkOperation.insert Incident_Helpers.email_franchisee franchisee.ev.FRANCH_NAME, franchisee.ev.FRANCH_EMAIL, incident, false

        return {customer, owner}

    escalate_incident: (incident, escalation_type) ->
        current_level = incident.level

        if current_level > 3
            return

        timestamp = Date.now()

        new_level = current_level + 1
        incident_doc_id = incident._id

        mongoBulkOperation = Docs.rawCollection().initializeUnorderedBulkOp();

        mongoBulkOperation.insert Incident_Helpers.generate_event 'escalate', incident_doc_id, "#{escalation_type} escalation from #{current_level} to #{new_level}.", incident.author_id, timestamp

        incident.level = new_level

        Incident_Helpers.handle_sla Meteor.userId(), incident, new_level, mongoBulkOperation

        mongoBulkOperation.find(_id: incident_doc_id).updateOne
            $set:
                level: new_level
                updated: timestamp
                escalation_timestamp: timestamp

        mongoBulkOperation.execute (error) ->
            if error
                console.error error



Meteor.methods
    submit_incident: (incident_doc_id)->
        incident = Docs.findOne incident_doc_id
        console.log 'submitting'
        timestamp = Date.now()

        mongoBulkOperation = Docs.rawCollection().initializeUnorderedBulkOp();

        {customer, owner} = Incident_Helpers.handle_sla Meteor.userId(), incident, 1, mongoBulkOperation

        mongoBulkOperation.find(_id: incident_doc_id).updateOne
            $set:
                submitted:true
                submitted_datetime: timestamp
                last_updated_datetime: timestamp
                assignment_timestamp: timestamp
                escalation_timestamp: timestamp
            $addToSet:
                assigned_to: owner._id

        mongoBulkOperation.insert Incident_Helpers.generate_event 'submit', incident_doc_id, "#{customer.username} submitted the incident.", customer._id, timestamp - 10
        Meteor.call 'notify_about_incident_submission', incident_doc_id, ->

        mongoBulkOperation.execute (error) ->
            if error
                console.error error

    escalate_incident: (doc_id)->
        incident = Docs.findOne doc_id

        Incident_Helpers.escalate_incident incident, 'Manual'

        return

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



    clear_incident_events: (incident_doc_id)->
        cursor = Docs.find
            parent_id: incident_doc_id
            type:'event'
        for event_doc in cursor.fetch()
            Docs.remove event_doc._id


    notify_about_incident_submission: (incident_doc_id)->
        incident = Docs.findOne incident_doc_id
        console.log 'notifying about ticket submission'
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

            # to: ["richard@janhub.com <richard@janhub.com>","zack@janhub.com <zack@janhub.com>", "Nicholas.Rose@premiumfranchisebrands.com <Nicholas.Rose@premiumfranchisebrands.com>"]

        mail_fields = {
            to: ["ej <repjackson@gmail.com>"]
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


        console.log mail_fields

        # Meteor.call 'send_email', mail_fields




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
