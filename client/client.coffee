@selected_tags = new ReactiveArray []


$.cloudinary.config
    cloud_name:"facet"

    
FlowRouter.notFound =
    action: ->
        BlazeLayout.render 'layout', 
            main: 'not_found'

Template.body.events
    'click .toggle_sidebar': -> $('.ui.sidebar').sidebar('toggle')

Template.registerHelper 'is_editing', () -> 
    # console.log 'this', @
    Session.equals 'editing_id', @_id

Template.registerHelper 'is_author', () ->  Meteor.userId() is @author_id

Template.registerHelper 'can_edit', () ->  Meteor.userId() is @author_id or Roles.userIsInRole(Meteor.userId(), 'admin')

Template.registerHelper 'publish_when', () -> moment(@publish_date).fromNow()


Template.registerHelper 'when', () -> moment(@timestamp).fromNow()


Template.registerHelper 'is_dev', () -> Meteor.isDevelopment


Template.sidebar.onRendered ->
    @autorun =>
        if @subscriptionsReady()
            Meteor.setTimeout ->
                $('.context.example .ui.sidebar')
                    .sidebar({
                        context: $('.context.example .bottom.segment')
                        dimPage: false
                        transition:  'push'
                    })
                    .sidebar('attach events', '.context.example .menu .toggle_sidebar.item')
            , 500
            
            
Template.camera.onRendered ->
    Webcam.on 'error', (err) ->
        console.log err
        # outputs error to console instead of window.alert
    Webcam.set
        width: 320
        height: 240
        dest_width: 640
        dest_height: 480
        image_format: 'jpeg'
        jpeg_quality: 90
    Webcam.attach '#webcam'

Template.camera.events 'click .snap': ->
    Webcam.snap (image) ->
        Session.set 'webcamSnap', image

Template.camera.helpers 
    image: -> Session.get 'webcamSnap'
