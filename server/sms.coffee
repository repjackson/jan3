Twilio = require 'twilio'
# { parse, format } = require 'libphonenumber-js'

twilio = Twilio(Meteor.settings.private.sms.sid, Meteor.settings.private.sms.token)
Meteor.methods
    send_sms: (to,body)->
        twilio.messages.create({
            to: to, 
            from: '+18442525977'
            body: body
        }, (err,res)->
            if err 
                throw new Meteor.Error 'text_not_sent', 'error sending text'
        )
        new_event_id = Docs.insert
            type:'event'
            event_type:'sms'
            text: "SMS was sent to #{to}: #{body}" 
            recipient: to
    
        
    sendEmail: (to, from, subject, text) ->
        @unblock()
        Email.send
            to: to
            from: from
            subject: subject
            text: text
        return

    gmail_test: ->
        Meteor.call 'sendEmail', 'eric <repjackson@gmail.com>', 'bob@example.com', 'Hello from Meteor!', 'This is a test of Email.send.'

        
# accountSid = 'AC7902add3a00bf69f1196b96e7b2f4122'; // Your Account SID from www.twilio.com/console
# authToken = 'your_auth_token';   // Your Auth Token from www.twilio.com/console

# twilio = require('twilio');
# client = new twilio(accountSid, authToken);

# client.messages.create({
#     body: 'Hello from Node',
#     to: '+12345678901',  // Text this number
#     from: '+12345678901' // From a valid Twilio number
# })
