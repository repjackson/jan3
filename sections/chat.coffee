if Meteor.isClient
    FlowRouter.route '/chat', action: ->
        BlazeLayout.render 'layout', main: 'chat'
    
    Template.chat.onCreated ->
        @autorun => Meteor.subscribe 'facet', 
            selected_tags.array()
            selected_keywords.array()
            selected_author_ids.array()
            selected_location_tags.array()
            selected_timestamp_tags.array()
            type='conversation'
            author_id=null
    
    Template.chat.helpers
        conversations: ->
            Docs.find   
                type:'conversation'
    
        messages: ->
            Docs.find
                type:'message'
    
    
    Template.chat.events
        'keydown #new_message': (e,t)->
            if e.which is 13
                new_message = $('#new_message').val().trim()
                if new_message.length > 0
                    Docs.insert 
                        text: new_message
                        type:'message'
                    $('#new_message').val('')

    Template.message.events
        'click .delete_comment': ->
            if confirm 'Delete comment?'
                Docs.remove @_id

