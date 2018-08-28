FlowRouter.route '/bugs', 
    name:'bugs'
    action: -> BlazeLayout.render 'layout', main: 'bugs'




Template.bugs.onCreated ->
    @autorun => Meteor.subscribe 'facet', 
        selected_tags.array()
        selected_author_ids.array()
        selected_location_tags.array()
        selected_timestamp_tags.array()
        type='bug'
        author_id=null
            
Template.bugs.helpers
    bugs: -> Docs.find {type:'bug'}, sort:timestamp:-1
            
Template.bug_edit.events
    'click #delete_bug': ->
        if confirm 'delete bug?'
            Docs.remove @_id
            FlowRouter.go '/bugs'
            