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
                console.log comment
                $('#new_comment').val ''
                new_comment_id = 
                    Docs.insert
                        type:'comment'
                        text:comment
                        parent_id:FlowRouter.getParam('doc_id')
                 
        'click .delete_comment': ->
            if confirm 'Delete Comment?'
                Docs.remove @_id

if Meteor.isServer
    Meteor.publish 'comments', (parent_id)->
        Docs.find
            type:'comment'
            parent_id:parent_id

                        
                        