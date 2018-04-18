@Docs = new Meteor.Collection 'docs'

Docs.before.insert (userId, doc)->
    doc.timestamp = Date.now()
    doc.author_id = Meteor.userId()
    return


# Docs.after.insert (userId, doc)->
#     console.log doc.tags
#     return

# Docs.after.update ((userId, doc, fieldNames, modifier, options) ->
#     doc.tag_count = doc.tags?.length
#     # Meteor.call 'generate_authored_cloud'
# ), fetchPrevious: true


Docs.helpers
    author: -> Meteor.users.findOne @author_id
    when: -> moment(@timestamp).fromNow()

# FlowRouter.route '/docs', action: (params) ->
#     BlazeLayout.render 'layout',
#         # cloud: 'cloud'
#         main: 'docs'

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
                main: 'view_doc'
    
    
    Template.view_doc.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
        
    # Template.view_doc.onRendered ->
        # @autorun =>
        #     if @subscriptionsReady()
        #         doc = Docs.findOne FlowRouter.getParam('doc_id')
        #         Meteor.setTimeout ->
        #             if doc
        #                 if doc.title
        #                     document.title = doc.title
        #             $('.ui.dropdown').dropdown()
        #         , 500
        
    
    Template.view_doc.helpers
        doc: -> Docs.findOne FlowRouter.getParam('doc_id')
        view_type: -> "view_#{@type}"
            

    Template.docs.onCreated -> 
        @autorun -> Meteor.subscribe('docs', selected_tags.array())

    Template.docs.helpers
        docs: -> 
            Docs.find { }, 
                sort:
                    tag_count: 1
                limit: 1
    
        tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else 'basic'

        selected_tags: -> selected_tags.array()

    
    # Template.view.helpers
    #     is_author: -> Meteor.userId() and @author_id is Meteor.userId()
    
    #     tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else 'basic'
    
    #     when: -> moment(@timestamp).fromNow()

    # Template.view.events
    #     'click .tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove(@valueOf()) else selected_tags.push(@valueOf())
    
    #     'click .edit': -> FlowRouter.go("/edit/#{@_id}")

    Template.docs.events
        'click #add': ->
            Meteor.call 'add', (err,id)->
                FlowRouter.go "/edit/#{id}"
    
        'keyup #quick_add': (e,t)->
            e.preventDefault
            tag = $('#quick_add').val().toLowerCase()
            if e.which is 13
                if tag.length > 0
                    split_tags = tag.match(/\S+/g)
                    $('#quick_add').val('')
                    Meteor.call 'add', split_tags
                    selected_tags.clear()
                    for tag in split_tags
                        selected_tags.push tag
    


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
        
