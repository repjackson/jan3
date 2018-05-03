@selected_author_ids = new ReactiveArray []


Template.username_facet.onCreated ->
    @autorun => 
        # Meteor.subscribe('facet', 
        #     selected_tags.array()
        #     selected_author_ids.array()
        #     selected_location_tags.array()
        #     selected_intention_tags.array()
        #     selected_timestamp_tags.array()
        #     type=@data.type
        #     )
        Meteor.subscribe 'usernames'

Template.username_facet.helpers
    author_tags: ->
        author_usernames = []
        
        for author_id in Author_ids.find().fetch()
            
            found_user = Meteor.users.findOne(author_id.text)
            # if found_user
            #     console.log Meteor.users.findOne(author_id.text).username
            author_usernames.push Meteor.users.findOne(author_id.text)
        author_usernames


    selected_author_ids: ->
        selected_author_usernames = []
        for selected_author_id in selected_author_ids.array()
            selected_author_usernames.push Meteor.users.findOne(selected_author_id).username
        selected_author_usernames
    
    settings: -> {
        position: 'bottom'
        limit: 10
        rules: [
            {
                collection: Watson_keywords
                field: 'name'
                matchAll: false
                template: Template.tag_result
            }
            ]
    }

Template.username_facet.events
    'click .select_author': ->
        selected_author = Meteor.users.findOne username: @username
        selected_author_ids.push selected_author._id
    'click .unselect_author': -> 
        selected_author = Meteor.users.findOne username: @valueOf()
        selected_author_ids.remove selected_author._id
    'click #clear_authors': -> selected_author_ids.clear()


