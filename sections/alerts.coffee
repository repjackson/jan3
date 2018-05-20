FlowRouter.route '/alerts', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'alerts'

if Meteor.isClient
    Template.alerts.onCreated -> 
        @autorun -> Meteor.subscribe('docs',[], 'alert')

    Template.alerts.helpers
        alerts: -> Docs.find type:'alert'
    
    Template.alert.events
    
    


Meteor.methods
    # add_alert: (subject_id, predicate, object_id) ->
    #     new_id = Docs.insert
    #         type: 'alert'
    #         subject_id: subject_id
    #         predicate: predicate
    #         object_id: object_id
    #     return new_id


if Meteor.isClient
    Template.alerts.onCreated ->
        @autorun => Meteor.subscribe 'alerts', Meteor.userId()
        # @autorun => 
        #     Meteor.subscribe('facet', 
        #         selected_theme_tags.array()
        #         selected_author_ids.array()
        #         selected_location_tags.array()
        #         selected_intention_tags.array()
        #         selected_timestamp_tags.array()
        #         type = 'alert'
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

    Template.alerts.helpers
        alerts: -> 
            Docs.find {
                type: 'alert'
                }, 
                sort: timestamp: -1
        
        
    Template.alerts.events
        'click #mark_all_read': ->
            if confirm 'Mark all alerts read?'
                Docs.update {},
                    $addToSet: read_by: Meteor.userId()
                    
    Template.alert.helpers
        product_segment_class: -> if Meteor.userId() in @read_by then 'basic' else ''
        
        subject_name: -> if @subject_id is Meteor.userId() then 'You' else @subject().name()
        object_name: -> if @object_id is Meteor.userId() then 'you' else @object().name()


if Meteor.isServer
    publishComposite 'received_alerts', ->
        {
            find: ->
                Docs.find
                    type: 'alert'
                    recipient_id: Meteor.userId()
            children: [
                { find: (alert) ->
                    Meteor.users.find 
                        _id: alert.author_id
                    }
                ]    
        }
        
    publishComposite 'all_alerts', ->
        {
            find: ->
                Docs.find type: 'alert'
            children: [
                { find: (alert) ->
                    Meteor.users.find 
                        _id: alert.subject_id
                    }
                { find: (alert) ->
                    Meteor.users.find 
                        _id: alert.object_id
                    }
                ]    
        }
        
        
    publishComposite 'unread_alerts', ->
        {
            find: ->
                Docs.find
                    type: 'alert'
                    recipient_id: Meteor.userId()
                    read: false
            children: [
                { find: (alert) ->
                    Meteor.users.find 
                        _id: alert.author_id
                    }
                ]    
        }
        
        
    Meteor.publish 'alert_subjects', (selected_subjects)->
        self = @
        match = {}
        
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        match.type = 'alert'

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
        cloud.forEach (alert_subject, i) ->
            self.added 'alert_subjects', Random.id(),
                name: alert_subject.name
                count: alert_subject.count
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