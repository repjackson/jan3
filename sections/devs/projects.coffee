if Meteor.isClient
    FlowRouter.route '/projects', action: ->
        BlazeLayout.render 'layout', 
            sub_nav:'dev_nav'
            main: 'projects'
    
    Template.projects.onCreated ->
        @autorun => Meteor.subscribe 'facet', 
            selected_tags.array()
            selected_keywords.array()
            selected_author_ids.array()
            selected_location_tags.array()
            selected_timestamp_tags.array()
            type='project'
            author_id=null
    
    Template.projects.onCreated ->
        Meteor.setTimeout ->
            $('.progress').progress()
        , 1000
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 1000
    
    
    
    
    Template.projects.helpers
        projects: -> 
            Docs.find type:'project'
        
        
        
    Template.projects.events
        'click .save_project': -> Session.set 'editing_id',null
        'click .edit_project': -> Session.set 'editing_id',@_id
        'keyup .project_text': (e,t)->
            e.preventDefault()
            val = $('.project_text').val().toLowerCase().trim()
            if e.which is 13 #enter
                Docs.update @_id,
                    $set: text: val
                Bert.alert "Updated Text", 'success', 'growl-top-right'
    
    Template.project_card.events
        'click #turn_on': ->
            # console.log @complete
            Docs.update {_id:@_id}, 
                $set: complete: true
    
        'click #turn_off': ->
            # console.log @complete
            Docs.update {_id:@_id}, 
                $set: complete: false


        