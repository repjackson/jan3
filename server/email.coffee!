Accounts.emailTemplates.siteName = "Jan-Pro, LLC"
Accounts.emailTemplates.from     = "Jan-Pro Mailer <no-reply@janpro.com>"

Accounts.emailTemplates.verifyEmail =
    subject: () -> return "Jan-Pro Email Verification"
 
    text: ( user, url )->
        emailAddress   = user.emails[0].address
        urlWithoutHash = url.replace( '#/', '' )
        supportEmail   = "support@janpro.com"
        emailBody      = "To verify your email address (#{emailAddress}) visit the following link:\n\n#{urlWithoutHash}\n\n If you did not request this verification, please ignore this email."
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
        
        
        # Email.send
        #     to: " #{service_author.profile.first_name} #{service_author.profile.last_name} <#{service_author.emails[0].address}>",
        #     from: "Tori Webster Inspires <admin@toriwebster.com>",
        #     subject: "New #{service.title} request from #{requester.profile.first_name} #{requester.profile.last_name}",
        #     html: 
        #         "<h4>#{requester.profile.first_name} requested #{service.title} for their document: </h4>
        #         #{recipient_doc.content} <br><br>
                
        #         <h4> Document type: #{recipient_doc.type}</h4>
        #         <h4> Document tags: #{recipient_doc.tags}</h4>
                
                
        #         Click <a href=#{message_link}> here to view the transaction.</a><br><br>
        #         "
            
        #     # html: 
        #     #     "<h4>#{message_author.profile.first_name} just sent the following message: </h4>
        #     #     #{text} <br>
        #     #     In conversation with tags: #{conversation_doc.tags}. \n
        #     #     In conversation with description: #{conversation_doc.description}. \n
        #     #     \n
        #     #     Click <a href="/view/#{_id}"
        #     # "
