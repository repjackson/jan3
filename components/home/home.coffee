if Meteor.isClient
    FlowRouter.route '/', action: ->
        BlazeLayout.render 'layout', 
            main: 'home'
    
    Template.home.onCreated ->
        @autorun -> Meteor.subscribe('featured_posts')
        @autorun -> Meteor.subscribe('readings')
    
    Template.home.helpers
        featured_posts: -> 
            Docs.find {featured:true},
                sort:
                    publish_date: -1
                limit: 10
                
        last_pool_reading: ->
            Docs.findOne
                type: 'reading'
                location: 'pool'
        last_indoor_hot_tub_reading: ->
            Docs.findOne
                type: 'reading'
                location: 'indoor_hot_tub'
        last_outdoor_hot_tub_reading: ->
            Docs.findOne
                type: 'reading'
                location: 'outdoor_hot_tub'
            
                
                
    Template.home.events
        # 'click #add_post': ->
        #     id = Docs.insert type: 'post'
        #     FlowRouter.go "/post/edit/#{id}"
    