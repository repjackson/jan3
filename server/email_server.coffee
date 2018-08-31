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
        Email.send
            to: mail_fields.to
            from: mail_fields.from
            subject: mail_fields.subject
            text: mail_fields.text
            html: mail_fields.html
        console.log 'classic email sent'

        # if Meteor.isProduction
        #     Meteor.Mailgun.send
        #         to: mail_fields.to
        #         from: mail_fields.from
        #         subject: mail_fields.subject
        #         text: mail_fields.text
        #         html: mail_fields.html
        #     console.log 'email sent from production'
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

    
 
