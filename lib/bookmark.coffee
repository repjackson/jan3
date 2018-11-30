if Meteor.isServer
    Meteor.publish 'my_bookmarks', ->
        Docs.find
            bookmark_ids:$in:[Meteor.userId()]



if Meteor.isClient
    Template.bookmark.onCreated ->
        @autorun -> Meteor.subscribe 'user_list_users', Template.parentData(4), 'bookmark_ids'

    Template.bookmark.helpers
        bookmarked: ->
            target = Template.parentData(4)
            if target.bookmark_ids and Meteor.userId() in target.bookmark_ids then true else false
        bookmark_users: ->
            target = Template.parentData(4)
            if target and target.bookmark_ids
                Meteor.users.find
                    _id: $in: target.bookmark_ids

    Template.bookmark.events
        'click .toggle_bookmark': (e,t)->
            target = Template.parentData(4)
            Meteor.call 'user_toggle_list', target, 'bookmark_ids'
