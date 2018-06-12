
FlowRouter.route '/dev', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        sub_nav: 'dev_nav'
        main: 'dev'
 
 
 
if Meteor.isClient
    Template.dev.events
    
    Template.dev_nav.onRendered ->
        # Meteor.setTimeout ->
        #     $('.item').popup()
        # , 400
        