@Docs = new Meteor.Collection 'docs'

Docs.before.insert (userId, doc)->
    timestamp = Date.now()
    doc.timestamp = timestamp
    # console.log moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
    date = moment(timestamp).format('Do')
    weekdaynum = moment(timestamp).isoWeekday()
    weekday = moment().isoWeekday(weekdaynum).format('dddd')
    month = moment(timestamp).format('MMMM')
    year = moment(timestamp).format('YYYY')

    date_array = [weekday, month, date, year]
    if _
        date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
    # date_array = _.each(date_array, (el)-> console.log(typeof el))
    # console.log date_array
    doc.timestamp_tags = date_array
    doc.author_id = Meteor.userId()
    return

Meteor.users.helpers
    name: -> 
        if @profile?.first_name and @profile?.last_name
            "#{@profile.first_name}  #{@profile.last_name}"
        else
            "#{@username}"
    last_login: -> 
        moment(@status?.lastLogin.date).fromNow()

    five_tags: -> if @tags then @tags[0..3]
    

Docs.helpers
    author: -> Meteor.users.findOne @author_id
    when: -> moment(@timestamp).fromNow()
    office: -> Docs.findOne @referenced_office_id
    customer: -> Docs.findOne @referenced_customer_id
    comment_count: -> Docs.find({type:'comment', parent_id:@_id}).count()

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
        insert: (user_id, doc) -> true
        # update: (user_id, doc) -> doc.author_id is user_id or Roles.userIsInRole(user_id, 'admin')
        # remove: (user_id, doc) -> doc.author_id is user_id or Roles.userIsInRole(user_id, 'admin')
        update: (user_id, doc) -> true
        remove: (user_id, doc) -> 'admin' in Meteor.user().roles
    
    
    publishComposite 'docs', (selected_tags, type)->
        {
            find: ->
                self = @
                match = {}
                if type then match.type = type
                # console.log match
                Docs.find match,
                    limit:20
            children: [
                {
                    find: (doc)-> Meteor.users.find _id:doc.author_id
                }
                {
                    find: (doc)-> Docs.find _id:doc.parent_id
                }
            ]
        }


    publishComposite 'incidents', (level)->
        {
            find: ->
                self = @
                match = {}
                # match.current_level = parseInt(level)
                match.type = 'incident'
                # console.log match
                Docs.find match,
                    limit:20
            children: [
                {
                    find: (doc)-> Meteor.users.find _id:doc.author_id
                }
                {
                    find: (doc)-> Docs.find _id:doc.parent_id
                }
            ]
        }



    
    # Meteor.publish 'docs', (selected_tags, type)->
    
    #     # user = Meteor.users.findOne @userId
    #     # current_herd = user.profile.current_herd
    
    #     self = @
    #     match = {}
    #     # selected_tags.push current_herd
    #     # match.tags = $all: selected_tags
    #     if selected_tags.length > 0 then match.tags = $all: selected_tags
    #     if type then match.type = type

    #     Docs.find match,
    #         limit: 20
            
    
    publishComposite 'doc', (id)->
        {
            find: -> Docs.find id
            children: [
                {
                    find: (doc)-> Meteor.users.find _id:doc.author_id
                }
                {
                    find: (doc)-> Docs.find _id:doc.referenced_office_id
                }
                {
                    find: (doc)-> Docs.find _id:doc.referenced_customer_id
                }
                {
                    find: (doc)-> Docs.find _id:doc.parent_id
                }
            ]
        }

    
    
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
        
