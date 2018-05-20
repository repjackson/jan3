if Meteor.isClient
    Template.comments.onCreated ->
        @autorun -> Meteor.subscribe 'comments', FlowRouter.getParam('doc_id')
    
    Template.comments.helpers
        comments: -> Docs.find { parent_id:FlowRouter.getParam('doc_id'), type:'comment'}
    
    
    Template.comments.onRendered ->
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 400
    
    Template.comments.events
        'keyup #new_comment': (e,t)->
            e.preventDefault()
            comment = $('#new_comment').val().trim()
            if e.which is 13 #enter
                # console.log comment
                $('#new_comment').val ''
                new_comment_id = 
                    Docs.insert
                        type:'comment'
                        text:comment
                        parent_id: @_id
                Meteor.call 'create_alert', 'comment', @_id, new_comment_id, (err,res)->
                    if err then console.error err
                    else
                        console.log res
        'click .delete_comment': ->
            if confirm 'delete comment?'
                Docs.remove @_id
                # console.log @_id
                
if Meteor.isServer
    Meteor.publish 'comments', (doc_id)->
        Docs.find
            parent_id: doc_id
            type:'comment'

    Meteor.methods 
        create_alert: (type, parent_id, comment_id)->
            if type is 'comment'
                new_alert_id = 
                    Docs.insert
                        type:'alert'
                        alert_type:'comment'
                        parent_id:parent_id
                        comment_id:comment_id
                return new_alert_id
            else
              throw new Meteor.Error 'unknown_type', 'unknown alert type'
