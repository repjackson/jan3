Twilio = require 'twilio'
# { parse, format } = require 'libphonenumber-js'

twilio = Twilio(Meteor.settings.private.sms.sid, Meteor.settings.private.sms.token)
# console.log Twilio
# console.log Meteor.settings.private.sms.sid
# console.log Meteor.settings.private.sms.secret
Meteor.methods
    sms_test: ->
        twilio.messages.create({
            body: 'Mr. Hammond, the phones are working.',
            to: '+19176643297', 
            from: '+18442525977'
        }, (err,res)->
            if err then console.log err
            else
                console.log res
        )
        
        
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
# .then((message) => console.log(message.sid));
