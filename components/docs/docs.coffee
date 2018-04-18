@Docs = new Meteor.Collection 'docs'

Docs.before.insert (userId, doc)->
    doc.timestamp = Date.now()
    doc.author_id = Meteor.userId()
    return


Docs.helpers
    author: -> Meteor.users.findOne @author_id
    when: -> moment(@timestamp).fromNow()

Meteor.methods
    add: (tags=[])->
        id = Docs.insert
            tags: tags
        # Meteor.call 'generate_person_cloud', Meteor.userId()
        return id


if Meteor.isClient
    FlowRouter.route '/view/:doc_id', 
        name: 'view'
        action: (params) ->
            BlazeLayout.render 'layout',
                # nav: 'nav'
                main: 'doc_view'
    
    
    Template.doc_view.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    
    Template.doc_view.helpers
        doc: -> Docs.findOne FlowRouter.getParam('doc_id')
        type_view: -> "#{@type}_view"
            


if Meteor.isServer
    Docs.allow
        insert: (user_id, doc) -> user_id
        # update: (user_id, doc) -> doc.author_id is user_id or Roles.userIsInRole(user_id, 'admin')
        # remove: (user_id, doc) -> doc.author_id is user_id or Roles.userIsInRole(user_id, 'admin')
        update: (user_id, doc) -> user_id
        remove: (user_id, doc) -> user_id
    
    
    
    
    Meteor.publish 'docs', (selected_tags, type)->
    
        # user = Meteor.users.findOne @userId
        # current_herd = user.profile.current_herd
    
        self = @
        match = {}
        # selected_tags.push current_herd
        # match.tags = $all: selected_tags
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        if type then match.type = type

        Docs.find match,
            limit: 20
            
    
    Meteor.publish 'doc', (id)->
        Docs.find id
    
    
    
    Meteor.publish 'doc_tags', (selected_tags)->
        
        user = Meteor.users.findOne @userId
        # current_herd = user.profile.current_herd
        
        self = @
        match = {}
        
        # selected_tags.push current_herd
        match.tags = $all: selected_tags

        
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'cloud, ', cloud
        cloud.forEach (tag, i) ->
            self.added 'tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i
    
        self.ready()
        
