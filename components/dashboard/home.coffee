if Meteor.isClient
    FlowRouter.route '/', action: ->
        BlazeLayout.render 'layout', 
            main: 'dashboard'
    
    Template.dashboard.onCreated ->
        @autorun -> Meteor.subscribe('docs', [], 'office')
        @autorun -> Meteor.subscribe('docs', [], 'person')
        @autorun -> Meteor.subscribe('docs', [], 'incident')
    
    Template.dashboard.onRendered ->
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 400

    
    
    Template.dashboard.helpers
        office: -> Docs.findOne type:'office'
        person: -> Docs.findOne type:'person'
        incidents: -> Docs.find {type:'incident'}, limit:5
    