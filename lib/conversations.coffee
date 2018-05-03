
Meteor.methods
    # add_conversation: (subject_id, predicate, object_id) ->
    #     new_id = Docs.insert
    #         type: 'conversation'
    #         subject_id: subject_id
    #         predicate: predicate
    #         object_id: object_id
    #     return new_id


if Meteor.isClient
    Template.conversations.onCreated ->
        @autorun => Meteor.subscribe 'conversations', Meteor.userId()
        # @autorun => 
        #     Meteor.subscribe('facet', 
        #         selected_theme_tags.array()
        #         selected_author_ids.array()
        #         selected_location_tags.array()
        #         selected_intention_tags.array()
        #         selected_timestamp_tags.array()
        #         type = 'conversation'
        #         author_id = null
        #         parent_id = null
        #         tag_limit = 20
        #         doc_limit = 10
        #         view_published = null
        #         view_read = Session.get('view_read')
        #         view_bookmarked = null
        #         view_resonates = null
        #         view_complete = null
        #         view_images = null
        #         view_lightbank_type = null
    
        #         )

    Template.conversations.helpers
        conversations: -> 
            Docs.find {
                type: 'conversation'
                }, 
                sort: timestamp: -1
        
        
        # conversations_allowed: ->
        #     # console.log conversation.permission
        #     if conversation.permission is 'denied' or 'default' 
        #         # console.log 'conversations are denied'
        #         # return false
        #     if conversation.permission is 'granted'
        #         # console.log 'yes granted'
        #         # return true
            
            
    Template.conversations.events
        # 'click #allow_conversations': ->
        #     conversation.requestPermission()
        
        # 'click #mark_all_read': ->
        #     if confirm 'Mark all conversations read?'
        #         Docs.update {},
        #             $addToSet: read_by: Meteor.userId()
                    
    Template.conversation.helpers
        conversation_segment_class: -> if Meteor.userId() in @read_by then 'basic' else ''
        
        subject_name: -> if @subject_id is Meteor.userId() then 'You' else @subject().name()
        object_name: -> if @object_id is Meteor.userId() then 'you' else @object().name()

    Template.conversation.events
    

if Meteor.isServer
    publishComposite 'received_conversations', ->
        {
            find: ->
                Docs.find
                    type: 'conversation'
                    recipient_id: Meteor.userId()
            children: [
                { find: (conversation) ->
                    Meteor.users.find 
                        _id: conversation.author_id
                    }
                ]    
        }
        
    publishComposite 'all_conversations', ->
        {
            find: ->
                Docs.find type: 'conversation'
            children: [
                { find: (conversation) ->
                    Meteor.users.find 
                        _id: conversation.subject_id
                    }
                { find: (conversation) ->
                    Meteor.users.find 
                        _id: conversation.object_id
                    }
                ]    
        }
        
        
    publishComposite 'unread_conversations', ->
        {
            find: ->
                Docs.find
                    type: 'conversation'
                    recipient_id: Meteor.userId()
                    read: false
            children: [
                { find: (conversation) ->
                    Meteor.users.find 
                        _id: conversation.author_id
                    }
                ]    
        }
        
        
    Meteor.publish 'conversation_subjects', (selected_subjects)->
        self = @
        match = {}
        
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        match.type = 'conversation'

        cloud = Docs.aggregate [
            { $match: match }
            { $project: subject_id: 1 }
            { $group: _id: '$subject_id', count: $sum: 1 }
            { $match: _id: $nin: selected_subjects }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'cloud, ', cloud
        cloud.forEach (conversation_subject, i) ->
            self.added 'conversation_subjects', Random.id(),
                name: conversation_subject.name
                count: conversation_subject.count
                index: i
    
        self.ready()
            
    
    # Meteor.publish 'usernames', (selectedTags, selectedUsernames, pinnedUsernames, viewMode)->
# Meteor.publish 'usernames', (selectedTags)->
    # self = @

    # match = {}
    # if selectedTags.length > 0 then match.tags = $all: selectedTags
    # # if selectedUsernames.length > 0 then match.username = $in: selectedUsernames

    # cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: username: 1 }
    #     { $group: _id: '$username', count: $sum: 1 }
    #     { $match: _id: $nin: selectedUsernames }
    #     { $sort: count: -1, _id: 1 }
    #     { $limit: 50 }
    #     { $project: _id: 0, text: '$_id', count: 1 }
    #     ]

    # cloud.forEach (username) ->
    #     self.added 'usernames', Random.id(),
    #         text: username.text
    #         count: username.count
    # self.ready()