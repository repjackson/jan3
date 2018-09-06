FlowRouter.route '/dev', action: ->
    BlazeLayout.render 'layout', 
        main: 'dev'

Template.dev.onCreated ->
    @autorun => Meteor.subscribe 'events_by_type', 'sms'

Template.dev.helpers
    events: -> Docs.find type:'event'
Template.dev.events
    'click #send_email': (e,t)->
        recipient = $('#recipient_email').val()
        message = $('#email_body').val()
        Meteor.call 'sendEmail', recipient, 'repjackson@gmail.com', 'test dev portal message', message, (err,res)->
            if err then console.log err
            else
                console.res
    
    'click #send_sms': (e,t)->
        recipient = $('#recipient_number').val()
        message = $('#sms_message').val()
        
        Meteor.call 'send_sms', recipient, message, (err,res)->
            if err then console.log err
            else
                console.res
    
    
    
                