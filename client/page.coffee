FlowRouter.route '/dev', action: ->
    BlazeLayout.render 'layout', 
        main: 'dev'
        
FlowRouter.route '/p/:page_slug/:jpid?', 
    action: (params, query_params)->
        BlazeLayout.render 'layout', 
            main: 'page'
        
Template.dev.onCreated ->
    @autorun => Meteor.subscribe 'events_by_type', 'sms'
    @autorun => Meteor.subscribe 'type', 'page'

Template.dev.helpers
    events: -> Docs.find type:'event'
    pages: -> Docs.find type:'page'

# Template.page_view.onCreated ->
#     # location.reload() 
#     @autorun => Meteor.subscribe 'blocks', FlowRouter.getQueryParam('doc_id')

    
Template.page.onCreated ->
    @autorun => Meteor.subscribe 'page_by_slug', FlowRouter.getParam('page_slug')
    @autorun => Meteor.subscribe 'blocks_by_page_slug', FlowRouter.getParam('page_slug')
    @autorun => Meteor.subscribe 'doc', FlowRouter.getQueryParam('doc_id')
    @autorun => Meteor.subscribe 'type', 'event_type'

    
Template.page.events
    'click #create_page': ->
        slug = FlowRouter.getParam('page_slug')
        Docs.insert
            type:'page'
            slug:slug
    
Template.page.helpers
    page_doc: -> 
        FlowRouter.watchPathChange();
        currentContext = FlowRouter.current();
        Docs.findOne
            type:'page'
            slug: FlowRouter.getParam('page_slug')
    
    current_page_slug: -> FlowRouter.getParam('page_slug')
    
    
Template.dev.events
    'click #send_email': (e,t)->
        recipient = $('#recipient_email').val()
        message = $('#email_body').val()
        Meteor.call 'sendEmail', recipient, 'repjackson@gmail.com', 'test dev portal message', message, (err,res)->
            if err then console.error err
    
    'click #send_sms': (e,t)->
        recipient = $('#recipient_number').val()
        message = $('#sms_message').val()
        
        Meteor.call 'send_sms', recipient, message, (err,res)->
            if err then console.error err
    
    
