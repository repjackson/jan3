FlowRouter.route '/bookmarks', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'bookmarks'

if Meteor.isClient
    Template.bookmarks.onCreated -> 
        @autorun -> Meteor.subscribe('bookmarks')

    Template.bookmarks.helpers
        bookmarks: -> 
            Docs.find 
                bookmarked_user_ids: $in: [Meteor.userId()]
    
    Template.bookmark.events
        'click .edit': -> FlowRouter.go("/edit/#{@_id}")

    Template.bookmarks.events
        # 'click #add_module': ->
        #     id = bookmarks.insert({})
        #     FlowRouter.go "/edit_module/#{id}"
    
    


if Meteor.isServer
    Meteor.publish 'bookmarks', ()->
    
        self = @
        match = {}
        # selected_tags.push current_herd
        # match.tags = $all: selected_tags
        # if selected_tags.length > 0 then match.tags = $all: selected_tags

        Docs.find 
            $in: bookmarked_user_ids: [Meteor.userId()]