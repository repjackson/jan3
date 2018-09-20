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

        
        
# Meteor.startup ->
#     Meteor.Mailgun.config
#         username: 'portalmailer@sandbox97641e5041e64bfd943374748157462b.mailgun.org'
#         password: 'portalmailer'
#     return


Meteor.methods 
    send_email: (mail_fields) ->
        # check([mail_fields.to, mail_fields.from, mail_fields.subject, mail_fields.text, mail_fields.html], [String]);
        # Let other method calls from the same client start running,
        # without waiting for the email sending to complete.
        console.log 'email'
        @unblock()
        Email.send
            to: mail_fields.to
            from: mail_fields.from
            subject: mail_fields.subject
            text: mail_fields.text
            html: mail_fields.html

        # if Meteor.isProduction
        #     Meteor.Mailgun.send
        #         to: mail_fields.to
        #         from: mail_fields.from
        #         subject: mail_fields.subject
        #         text: mail_fields.text
        #         html: mail_fields.html
        # if Meteor.isDevelopment
            
        #     Meteor.Mailgun.send
        #         to: mail_fields.to
        #         from: mail_fields.from
        #         subject: mail_fields.subject
        #         text: mail_fields.text
        #         html: mail_fields.html
        # return
        
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
        
    
    
    send_email_about_task_assignment:(task_doc_id, username)->
        task_doc = Docs.findOne task_doc_id
        
        assigned_to_user = Meteor.users.findOne username:username
        task_link = "https://www.jan.meteorapp.com/v/#{task_doc._id}"
        
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
        incident = Docs.findOne incident_doc_id
        
        assigned_to_user = Meteor.users.findOne username:username
        incident_link = "https://www.jan.meteorapp.com/p/incident_admin_view?doc_id=#{incident._id}"
        complete_incident_link = "https://www.jan.meteorapp.com/p/incident_admin_view?doc_id=#{incident._id}&mark_complete=true"
        
        mail_fields = {
            # to: ["<#{assigned_to_user.emails[0].address}>"]
            to: 'repjackson@gmail.com'
            from: "Jan-Pro Customer Portal <portal@jan-pro.com>"
            subject: "Incident Assignment"
            html: "<h4>You have been assigned to incident ##{incident.incident_number} from customer: #{incident.customer_name}.</h4>
                <h5>Type: #{incident.incident_type}</h5>
                <h5>Number: #{incident.incident_number}</h5>
                <h5>Details: #{incident.incident_details}</h5>
                <h5>Timestamp: #{incident.timestamp}</h5>
                <h5>Office: #{incident.incident_office_name}</h5>
                <h5>Status: #{incident.status}</h5>
                <h5>Service Date: #{incident.service_date}</h5>
                <p>view the incident <a href=#{incident_link}>here</a>.
                <p>Mark task complete <a href=#{complete_incident_link}>here</a>.</p>
            "
        }
        Meteor.call 'send_email', mail_fields
