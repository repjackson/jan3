
FlowRouter.route '/dev', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        sub_nav: 'dev_nav'
        main: 'dev'
 
 
 
if Meteor.isClient
    Template.user_table.onCreated ->
        @autorun ->  Meteor.subscribe 'users'
    
    
    Template.user_table.helpers
        users: -> Meteor.users.find {}
    
    Template.dev.events
        'click #call_ev': ->
            Meteor.call 'call_ev', (err,res)->
                if err then console.error err
                else
                    console.log res
    
    Template.dev_nav.onRendered ->
        Meteor.setTimeout ->
            $('.item').popup()
        , 400
        