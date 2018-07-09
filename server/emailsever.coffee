Meteor.startup ->
    Meteor.Mailgun.config
        username: 'portalmailer@sandbox97641e5041e64bfd943374748157462b.mailgun.org'
        password: 'portalmailer'
    return
# In your server code: define a method that the client can call
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
