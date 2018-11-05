if Meteor.isClient
    Template.admin_stats.onCreated ()->
        @autorun => Meteor.subscribe 'jpid', FlowRouter.getQueryParam 'jpid'
        @autorun => Meteor.subscribe 'type', 'rule'
        @autorun => Meteor.subscribe 'admin_stats'

    Template.admin_stats.helpers
        page_office: ->
            Docs.findOne
                office_jpid: FlowRouter.getQueryParam 'jpid'
        rules: -> Docs.find {type:'rule'}, sort:number:-1

    Template.count_view.helpers
        stat_doc: ->
            stat = Stats.findOne
                name:@name

