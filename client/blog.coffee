FlowRouter.route '/blog', action: ->
    BlazeLayout.render 'layout', 
        sub_nav: 'admin_nav'
        main: 'blog'


Template.blog.onCreated ->
    # @autorun => Meteor.subscribe 'type', 'post'
    @autorun => Meteor.subscribe 'count', 'post'
    @autorun => Meteor.subscribe 'incomplete_post_count'
    @autorun => Meteor.subscribe 'facet', 
        selected_tags.array()
        selected_author_ids.array()
        selected_location_tags.array()
        selected_timestamp_tags.array()
        type='post'
        author_id=null


    
Template.blog.onRendered ->
    # $('.indicating.progress').progress();
    

Template.post_segment.onCreated ->
    # @autorun => Meteor.subscribe 'type', 'post'
    # @autorun => Meteor.subscribe 'post', @data._id

    
Template.post_edit.onCreated ->
    # @autorun => Meteor.subscribe 'type', 'post'
    @autorun => Meteor.subscribe 'post', @data._id

    
Template.post_view.onCreated ->
    # @autorun => Meteor.subscribe 'type', 'post'
    @autorun => Meteor.subscribe 'post', @data._id

    
    
Template.blog.helpers
    post_docs: ->  Docs.find { type:'post' }

Template.post_edit.helpers
    post: -> Doc.findOne FlowRouter.getParam('doc_id')
    
Template.post_edit.events
    'click #delete': ->
        template = Template.currentData()
        swal {
            title: 'Delete post?'
            # text: 'Confirm delete?'
            type: 'error'
            animation: false
            showCancelButton: true
            closeOnConfirm: true
            cancelButtonText: 'Cancel'
            confirmButtonText: 'Delete'
            confirmButtonColor: '#da5347'
        }, =>
            doc = Docs.findOne FlowRouter.getParam('doc_id')
            # console.log doc
            Docs.remove doc._id, ->
                FlowRouter.go "/blog"

