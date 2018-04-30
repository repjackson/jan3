if Meteor.isClient
    FlowRouter.route '/', action: ->
        BlazeLayout.render 'layout', 
            sub_nav:'customer_menu'
            main: 'dashboard'
    
    Template.dashboard.onCreated ->
        @autorun -> Meteor.subscribe('docs', [], 'office')
        @autorun -> Meteor.subscribe('docs', [], 'person')
        @autorun -> Meteor.subscribe('docs', [], 'incident')
    
    Template.dashboard.onRendered ->
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 400

    
    
    Template.local_office_information.helpers
        office: -> Docs.findOne type:'office'
    Template.general_account_info.helpers
        person: -> Docs.findOne type:'person'
    Template.dashboard.helpers
        person: -> Docs.findOne type:'person'
    Template.incident_widget.helpers
        incidents: -> Docs.find {type:'incident'}, limit:3
    