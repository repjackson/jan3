# Accounts.emailTemplates.siteName = "Jan-Pro, LLC"
# Accounts.emailTemplates.from     = "JP Admin <no-reply@jan-pro.com>"

# Accounts.emailTemplates.verifyEmail =
#     subject: () -> "Jan-Pro Customer Portal Email Verification"
 
#     text: ( user, url )->
#         emailAddress   = user.emails[0].address
#         urlWithoutHash = url.replace( '#/', '' )
#         supportEmail   = "support@jan-pro.com"
#         emailBody      = "To verify your email address (#{emailAddress}) visit the following link:\n\n#{urlWithoutHash}\n\n If you did not request this verification, please ignore this email. If you feel something is wrong, please contact our support team: #{supportEmail}."
#         return emailBody



#     # create_transaction: (service_id, recipient_doc_id, sale_dollar_price=0, sale_point_price=0)->
#     #     service = Docs.findOne service_id
#     #     service_author = Meteor.users.findOne service.author_id
#     #     recipient_doc = Docs.findOne recipient_doc_id
        
#     #     requester = Meteor.users.findOne recipient_doc.author_id

#     #     new_transaction_id = Docs.insert
#     #         type: 'transaction'
#     #         parent_id: service_id
#     #         author_id: Meteor.userId()
#     #         object_id: recipient_doc_id
#     #         sale_dollar_price: sale_dollar_price
#     #         sale_point_price: sale_point_price

#     #     message_link = "https://www.toriwebster.com/view/#{new_transaction_id}"
        
        
        
Meteor.startup ->
    Meteor.Mailgun.config
        username: 'portalmailer@sandbox97641e5041e64bfd943374748157462b.mailgun.org'
        password: 'portalmailer'
    return


Meteor.methods 
    send_email: (mail_fields) ->
        # console.log 'about to send email'
        # console.log 'mail fields', mail_fields
        # check([mail_fields.to, mail_fields.from, mail_fields.subject, mail_fields.text, mail_fields.html], [String]);
        # Let other method calls from the same client start running,
        # without waiting for the email sending to complete.
        @unblock()
        if Meteor.isProduction
            Meteor.Mailgun.send
                to: mail_fields.to
                from: mail_fields.from
                subject: mail_fields.subject
                text: mail_fields.text
                html: mail_fields.html
            console.log 'email sent from production'
        # if Meteor.isDevelopment
            # console.log 'email sending from dev'
            
            # Meteor.Mailgun.send
            #     to: mail_fields.to
            #     from: mail_fields.from
            #     subject: mail_fields.subject
            #     text: mail_fields.text
            #     html: mail_fields.html
            # console.log 'email sent from dev'
        return
        
    send_message: (to_username, from_username, message_text)->    
        Docs.insert
            type:'message'
            from_username:from_username
            to_username: to_username
            text: message_text
        
    beta_send_email: (subject, html) ->
        mail_fields = {
            to: ["richard@janhub.com <richard@janhub.com>","zack@janhub.com <zack@janhub.com>", "Nicholas.Rose@premiumfranchisebrands.com <Nicholas.Rose@premiumfranchisebrands.com>"]
            from: "Jan-Pro Customer Portal <portal@jan-pro.com>"
            subject: subject
            html: html
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
        escalation_primary_contact_value = office_doc["escalation_#{incident.level}_#{incident.incident_type}_primary_contact"]
        escalation_secondary_contact_value = office_doc["escalation_#{incident.level}_#{incident.incident_type}_secondary_contact"]
        
        escalation_franchisee_value = office_doc["escalation_#{incident.level}_#{incident.incident_type}_contact_franchisee"]
        escalation_customer_value = office_doc["escalation_#{incident.level}_#{incident.incident_type}_contact_customer"]
        
        # console.log escalation_franchisee_value
        
        # console.log "escalation_#{incident.level}_secondary_contact"
        # console.log 'escalation_primary_contact_value',escalation_primary_contact_value
        # console.log 'escalation_secondary_contact_value',escalation_secondary_contact_value
        mail_fields = {
            to: ["richard@janhub.com <richard@janhub.com>","zack@janhub.com <zack@janhub.com>", "Nicholas.Rose@premiumfranchisebrands.com <Nicholas.Rose@premiumfranchisebrands.com>"]
            from: "Jan-Pro Customer Portal <portal@jan-pro.com>"
            subject: "Incident from #{incident.customer_name} has been escalated to #{incident.level}."
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
                    <li>Primary Office Contact: #{escalation_primary_contact_value}</li>
                    <li>Secondary Office Contact: #{escalation_secondary_contact_value}</li>
                    <li>Franchisee: #{escalation_franchisee_value}, #{franchisee.ev.FRANCHISEE} at #{franchisee.ev.FRANCH_EMAIL}</li>
                </ul>
            "
        }
        
        Meteor.call 'send_message', escalation_primary_contact_value, 'system_escalation_bot', "You have been notified as the primary contact for a #{incident.incident_type} escalation to level #{incident.level} from #{incident.customer_name}."
        Meteor.call 'send_message', escalation_secondary_contact_value, 'system_escalation_bot', "You have been notified as the secondary contact for a #{incident.incident_type} escalation to level #{incident.level} from #{incident.customer_name}."
        
        
        
        Meteor.call 'create_event', incident_id, 'emailed_primary_contact', "#{escalation_primary_contact_value} has been emailed as the primary contact for a #{incident.incident_type} escalation to level #{incident.level}."
        Meteor.call 'create_event', incident_id, 'emailed_secondary_contact', "#{escalation_secondary_contact_value} has been emailed as the secondary contact for a #{incident.incident_type} escalation to level #{incident.level}."
        if escalation_franchisee_value
            Meteor.call 'create_event', incident_id, 'emailed_franchisee_contact', "Franchisee #{franchisee.ev.FRANCHISEE} has been emailed for a #{incident.incident_type} escalation to level #{incident.level}."
            Meteor.call 'send_message', franchisee.ev.FRANCHISEE, 'system_escalation_bot', "You have been notified as the franchisee for a #{incident.incident_type} escalation to level #{incident.level} from #{incident.customer_name}."
        if escalation_customer_value
            Meteor.call 'create_event', incident_id, 'emailed_franchisee_contact', "Franchisee #{franchisee.ev.FRANCHISEE} has been emailed for a #{incident.incident_type} escalation to level #{incident.level}."
            Meteor.call 'send_message', incident.customer_name, 'system_escalation_bot', "You have been notified as the customer for an incident submission."

        #{escalation_primary_contact_value}
        
        
        Meteor.call 'send_email', mail_fields
    #         # html: 
    #         #     "<h4>#{message_author.profile.first_name} just sent the following message: </h4>
    #         #     #{text} <br>
    #         #     In conversation with tags: #{conversation_doc.tags}. \n
    #         #     In conversation with description: #{conversation_doc.description}. \n
    #         #     \n
    #         #     Click <a href="/view/#{_id}"
    #         # "
    
    
    
    send_email_about_task_assignment:(task_doc_id, username)->
        task_doc = Docs.findOne task_doc_id
        
        assigned_to_user = Meteor.users.findOne username:username
        task_link = "https://www.jan.meteorapp.com/view/#{task_doc._id}"
        
        mail_fields = {
            to: ["<#{assigned_to_user.emails[0].address}>"]
            from: "Jan-Pro Customer Portal <portal@jan-pro.com>"
            subject: "Task Assignment"
            html: "<h4>You have been assigned to task #{task_doc.title}..</h4>
                <ul>
                    <li>Completed: #{task_doc.complete}</li>
                    <li>Due Date: #{task_doc.due_date}</li>
                    <li>Tags: #{task_doc.tags}</li>
                </ul>
                <p>view the task <a href=#{task_link}>here</a>.
            "
        }
        Meteor.call 'send_email', mail_fields

    
    send_email_about_incident_assignment:(incident_doc_id, username)->
        incident_doc = Docs.findOne incident_doc_id
        
        assigned_to_user = Meteor.users.findOne username:username
        incident_link = "https://www.jan.meteorapp.com/view/#{incident_doc._id}"
        unnassign_self_link = "https://www.jan.meteorapp.com/view/#{incident_doc._id}?username=#{assigned_to_user.username}"
        
        mail_fields = {
            to: ["<#{assigned_to_user.emails[0].address}>"]
            from: "Jan-Pro Customer Portal <portal@jan-pro.com>"
            subject: "Incident Assignment"
            html: "<h4>You have been assigned to incident ##{incident_doc.incident_number} from customer: #{incident_doc.customer_name}.</h4>
                <h5>Type: #{incident_doc.incident_type}</h5>
                <h5>Number: #{incident_doc.incident_number}</h5>
                <h5>Details: #{incident_doc.incident_details}</h5>
                <h5>Timestamp: #{incident_doc.timestamp}</h5>
                <h5>Office: #{incident_doc.incident_office_name}</h5>
                <h5>Status: #{incident_doc.status}</h5>
                <h5>Service Date: #{incident_doc.service_date}</h5>
                <p>View the incident <a href=#{incident_link}>here</a>.</p>
                <p>Mark task complete <a href=#{unnassign_self_link}>here</a>.</p>
            "
        }
        Meteor.call 'send_email', mail_fields

    
    
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
        # escalation_1_primary_contact_franchisee: true,
        initial_primary_contact_value = office_doc["escalation_1_#{incident.incident_type}_primary_contact"]
        initial_secondary_contact_value = office_doc["escalation_1_#{incident.incident_type}_secondary_contact"]
        
        initial_franchisee_value = office_doc["escalation_1_#{incident.incident_type}_contact_franchisee"]
        
        # console.log 'initial_primary_contact_value', initial_primary_contact_value
        # console.log 'initial_secondary_contact_value', initial_secondary_contact_value
        mail_fields = {
            to: ["richard@janhub.com <richard@janhub.com>","zack@janhub.com <zack@janhub.com>", "Nicholas.Rose@premiumfranchisebrands.com <Nicholas.Rose@premiumfranchisebrands.com>"]
            from: "Jan-Pro Customer Portal <portal@jan-pro.com>"
            subject: "Incident from #{incident.customer_name} has been submitted."
            text: ''
            html: "<h4>Incident from #{incident.customer_name} has been submitted by customer.</h4>
                <h5>Type: #{incident.incident_type}</h5>
                <h5>Number: #{incident.incident_number}</h5>
                <h5>Details: #{incident.incident_details}</h5>
                <h5>Timestamp: #{incident.timestamp}</h5>
                <h5>Office: #{incident.incident_office_name}</h5>
                <h5>Status: #{incident.status}</h5>
                <h5>Service Date: #{incident.service_date}</h5>
                <h4>This will notify</h4>
                <h5>Primary Office Contact: #{initial_primary_contact_value}</h5>
                <h5>Secondary Office Contact: #{initial_secondary_contact_value}</h5>
                <h5>Franchisee: #{initial_franchisee_value}, #{franchisee.ev.FRANCHISEE} at #{franchisee.ev.FRANCH_EMAIL}</h5>
            "
        }
        Meteor.call 'create_event', incident_id, 'emailed_primary_contact', "#{initial_primary_contact_value} has been emailed as the primary contact for initial submission."
        Meteor.call 'create_event', incident_id, 'emailed_secondary_contact', "#{initial_secondary_contact_value} has been emailed as the secondary contact for initial submission."
        if initial_franchisee_value
            Meteor.call 'create_event', incident_id, 'emailed_franchisee_contact', "Franchisee #{franchisee.ev.FRANCHISEE} has been emailed for incident submission."

        #{escalation_primary_contact_value}
        
        
        Meteor.call 'send_email', mail_fields
    #         # html: 
    #         #     "<h4>#{message_author.profile.first_name} just sent the following message: </h4>
    #         #     #{text} <br>
    #         #     In conversation with tags: #{conversation_doc.tags}. \n
    #         #     In conversation with description: #{conversation_doc.description}. \n
    #         #     \n
    #         #     Click <a href="/view/#{_id}"
    #         # "
    
    
    
    