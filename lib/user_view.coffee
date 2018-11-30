if Meteor.isClient
    Template.user_view.onCreated ->
        delta = Docs.findOne type:'delta'
        if delta.viewing_username
            @autorun -> Meteor.subscribe 'user_from_name', delta.viewing_username

    Template.user_view.helpers
        target_user: ->
            delta = Docs.findOne type:'delta'
            Meteor.users.findOne
                username: delta.viewing_username

    Template.bookmark.events
        'click .toggle_bookmark': (e,t)->
            target = Template.parentData(4)
            Meteor.call 'user_toggle_list', target, 'bookmark_ids'




if Meteor.isServer
    Meteor.publish 'user_from_name', (username)->
        Meteor.users.find   
            username:username
        