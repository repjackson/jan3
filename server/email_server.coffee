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
    sendEmail: (mailFields) ->
        console.log 'about to send email...'
        console.log mailFields
        # check([mailFields.to, mailFields.from, mailFields.subject, mailFields.text, mailFields.html], [String]);
        # Let other method calls from the same client start running,
        # without waiting for the email sending to complete.
        @unblock()
        if Meteor.isProduction
            Meteor.Mailgun.send
                to: mailFields.to
                from: mailFields.from
                subject: mailFields.subject
                text: mailFields.text
                html: mailFields.html
            console.log 'email sent from prod'
        if Meteor.isDevelopment
            console.log 'email sending from dev'
            Docs.insert
                type:'message'
                mail_fields: mailFields
            # Email.send
            #     to: mailFields.to
            #     from: mailFields.from
            #     subject: mailFields.subject
            #     text: mailFields.text
            #     html: mailFields.html
            # console.log 'email sent from dev'
        else
            console.log 'not prod or dev'
        return
        
        
    email_about_escalation: (incident_id)->
        incident = Docs.findOne incident_id
        office_doc = Docs.findOne {
            "ev.MASTER_LICENSEE":incident.incident_office_name
            type:'office'
        }
        # escalation_1_primary_contact_franchisee: true,
        escalation_primary_contact_value = office_doc["escalation_#{incident.level}_primary_contact"]
        escalation_secondary_contact_value = office_doc["escalation_#{incident.level}_secondary_contact"]
        console.log incident
        console.log office_doc
        console.log "escalation_#{incident.level}_secondary_contact"
        console.log escalation_primary_contact_value
        console.log escalation_secondary_contact_value
        mailFields = {
            to: ["richard@janhub.com <richard@janhub.com>","zack@janhub.com <zack@janhub.com>"]
            from: "Jan-Pro Customer Portal <portal@jan-pro.com>"
            subject: "Incident from #{incident.customer_name} has been escalated to #{incident.level}."
            text: ''
            html: "<h4>Incident from #{incident.customer_name} escalated to #{incident.level}.</h4>
                <h5>Type: #{incident.incident_type}</h5>
                <h5>Details: #{incident.incident_details}</h5>
                <h5>Office: #{incident.incident_office_name}</h5>
                <h5>Status: #{incident.status}</h5>
                <h5>Service Date: #{incident.service_date}</h5>
                <h4>This will notify</h4>
                <h5>Primary Office Contact: #{escalation_primary_contact_value}</h5>
                <h5>Secondary Office: #{escalation_secondary_contact_value}</h5>
            "
        }
        Meteor.call 'create_event', incident_id, 'emailed_primary_contact', "#{escalation_primary_contact_value} has been emailed as the primary contact for escalation to level #{incident.level}."
        Meteor.call 'create_event', incident_id, 'emailed_secondary_contact', "#{escalation_secondary_contact_value} has been emailed as the secondary contact for escalation to level #{incident.level}."

        #{escalation_primary_contact_value}
        
        
        Meteor.call 'sendEmail', mailFields
    #         # html: 
    #         #     "<h4>#{message_author.profile.first_name} just sent the following message: </h4>
    #         #     #{text} <br>
    #         #     In conversation with tags: #{conversation_doc.tags}. \n
    #         #     In conversation with description: #{conversation_doc.description}. \n
    #         #     \n
    #         #     Click <a href="/view/#{_id}"
    #         # "
    
    
    
    