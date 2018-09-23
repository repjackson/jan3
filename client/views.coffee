Template.comments_view.onCreated ->
    @autorun =>  Meteor.subscribe 'type', 'event_type'
