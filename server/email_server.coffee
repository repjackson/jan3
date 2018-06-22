Accounts.emailTemplates.siteName = "Jan-Pro, LLC"
Accounts.emailTemplates.from     = "JP Admin <no-reply@jan-pro.com>"

Accounts.emailTemplates.verifyEmail =
    subject: () -> "Jan-Pro Customer Portal Email Verification"
 
    text: ( user, url )->
        emailAddress   = user.emails[0].address
        urlWithoutHash = url.replace( '#/', '' )
        supportEmail   = "support@jan-pro.com"
        emailBody      = "To verify your email address (#{emailAddress}) visit the following link:\n\n#{urlWithoutHash}\n\n If you did not request this verification, please ignore this email. If you feel something is wrong, please contact our support team: #{supportEmail}."
        return emailBody



    # create_transaction: (service_id, recipient_doc_id, sale_dollar_price=0, sale_point_price=0)->
    #     service = Docs.findOne service_id
    #     service_author = Meteor.users.findOne service.author_id
    #     recipient_doc = Docs.findOne recipient_doc_id
        
    #     requester = Meteor.users.findOne recipient_doc.author_id

    #     new_transaction_id = Docs.insert
    #         type: 'transaction'
    #         parent_id: service_id
    #         author_id: Meteor.userId()
    #         object_id: recipient_doc_id
    #         sale_dollar_price: sale_dollar_price
    #         sale_point_price: sale_point_price

    #     message_link = "https://www.toriwebster.com/view/#{new_transaction_id}"
        
Meteor.methods
    email_about_escalation_two: (incident_id)->
        incident = Docs.findOne incident_id
        console.log incident
        mailFields = {
            to: "repjackson@gmail.com <repjackson@gmail.com>"
            from: "Jan-Pro <support@jan-pro.com>"
            subject: "Incident has been escalated to 2"
            text: ''
            html: "<h4>Incident from #{incident.customer_name} escalated to two.</h4>
                <h5>incident_type: #{incident.incident_type}</h5>
                <h5>incident_details: #{incident.incident_details}</h5>
                <h5>current_level: #{incident.current_level}</h5>
                <h5>status: #{incident.status}</h5>
                <h5>service_date: #{incident.service_date}</h5>
            "
        }
        Meteor.call 'sendEmail', mailFields
    #         # html: 
    #         #     "<h4>#{message_author.profile.first_name} just sent the following message: </h4>
    #         #     #{text} <br>
    #         #     In conversation with tags: #{conversation_doc.tags}. \n
    #         #     In conversation with description: #{conversation_doc.description}. \n
    #         #     \n
    #         #     Click <a href="/view/#{_id}"
    #         # "
    
    
    
    email_about_escalation_three: (incident_id)->
        incident = Docs.findOne incident_id
        console.log incident
        mailFields = {
            to: "repjackson@gmail.com <repjackson@gmail.com>"
            from: "Jan-Pro <support@jan-pro.com>"
            subject: "Incident has been escalated to 3"
            text: ''
            html: "<h4>Incident from #{incident.customer_name} escalated to two.</h4>
                <h5>incident_type: #{incident.incident_type}</h5>
                <h5>incident_details: #{incident.incident_details}</h5>
                <h5>current_level: #{incident.current_level}</h5>
                <h5>status: #{incident.status}</h5>
                <h5>service_date: #{incident.service_date}</h5>
            "
        }
        Meteor.call 'sendEmail', mailFields
    #         # html: 
    #         #     "<h4>#{message_author.profile.first_name} just sent the following message: </h4>
    #         #     #{text} <br>
    #         #     In conversation with tags: #{conversation_doc.tags}. \n
    #         #     In conversation with description: #{conversation_doc.description}. \n
    #         #     \n
    #         #     Click <a href="/view/#{_id}"
    #         # "
    
    
    
        email_about_escalation_four: (incident_id)->
        incident = Docs.findOne incident_id
        console.log incident
        mailFields = {
            to: "repjackson@gmail.com <repjackson@gmail.com>"
            from: "Jan-Pro <support@jan-pro.com>"
            subject: "Incident has been escalated to 4"
            text: ''
            html: "<h4>Incident from #{incident.customer_name} escalated to two.</h4>
                <h5>incident_type: #{incident.incident_type}</h5>
                <h5>incident_details: #{incident.incident_details}</h5>
                <h5>current_level: #{incident.current_level}</h5>
                <h5>status: #{incident.status}</h5>
                <h5>service_date: #{incident.service_date}</h5>
            "
        }
        Meteor.call 'sendEmail', mailFields
    #         # html: 
    #         #     "<h4>#{message_author.profile.first_name} just sent the following message: </h4>
    #         #     #{text} <br>
    #         #     In conversation with tags: #{conversation_doc.tags}. \n
    #         #     In conversation with description: #{conversation_doc.description}. \n
    #         #     \n
    #         #     Click <a href="/view/#{_id}"
    #         # "
    
    
    
    