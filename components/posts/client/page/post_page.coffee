Template.post_page.onCreated ->
    @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')



Template.post_page.helpers
    post: -> Docs.findOne FlowRouter.getParam('doc_id')


Template.post_page.events
    'click .edit_post': ->
        FlowRouter.go "/post/edit/#{@_id}"
