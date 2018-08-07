if Meteor.isClient
    FlowRouter.route '/stats', action: ->
        BlazeLayout.render 'layout', 
            sub_nav: 'admin_nav'
            main: 'stats'
    
    
    Template.stats.onCreated ->
        @autorun => Meteor.subscribe 'stats'
    Template.stats.helpers
        stats: ->  Stats.find {}
        
        fields: -> [
            {
                key:'doc_type'
                label:'Doc Type'
            }
            {
                key:'stat_type'
                label:'Stat Type'
            }
        ]
            
            