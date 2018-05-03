if Meteor.isClient
    Template.comments.onCreated ->
        # @autorun -> Meteor.subscribe 'comments', Session.get('editing_id')
    
    Template.comments.helpers
        # comments: -> Docs.find { parent_id:Session.get('editing_id'), type:'comment'}
    
    
    Template.comments.onRendered ->
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 400
    
    Template.comments.events
        'keyup #new_comment': (e,t)->
            e.preventDefault()
            comment = $('#new_comment').val().trim()
            if e.which is 13 #enter
                console.log comment
                $('#new_comment').val ''
                new_comment_id = 
                    Docs.insert
                        type:'comment'
                        text:comment
                        parent_id:Session.get('editing_id')
                 
        'click .delete_comment': ->
            if confirm 'delete comment?'
                Docs.remove @_id
                # console.log @_id