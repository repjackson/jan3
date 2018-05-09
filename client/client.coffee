@selected_tags = new ReactiveArray []

$.cloudinary.config
    cloud_name:"facet"


FlowRouter.notFound =
    action: ->
        BlazeLayout.render 'layout', 
            main: 'not_found'
Meteor.startup( () =>
    GoogleMaps.load
        key: 'AIzaSyAK_vkvxDH5vsqGkd0Qn-dDmq-rShTA7UA',
        libraries: 'places'
)




Template.body.events
    'click .toggle_sidebar': -> $('.ui.sidebar').sidebar('toggle')

Template.registerHelper 'is_editing', () -> 
    # console.log 'this', @
    Session.equals 'editing_id', @_id

Template.registerHelper 'is_author', () ->  Meteor.userId() is @author_id

Template.registerHelper 'can_edit', () ->  Meteor.userId() is @author_id or 'admin' in Meteor.user().roles

Template.registerHelper 'to_percent', (number) -> (number*100).toFixed()         

Template.registerHelper 'publish_when', () -> moment(@publish_date).fromNow()

Template.registerHelper 'doc', () -> Docs.findOne FlowRouter.getParam('doc_id')

Template.registerHelper 'when', () -> moment(@timestamp).fromNow()

Template.registerHelper 'formal_when', () -> moment(@timestamp).format('MMMM Do YYYY, h:mm:ss a')


Template.registerHelper 'key_value', (key) -> 
    doc_field = Template.parentData(2)
    current_doc = Template.parentData(5)
    # console.log doc_field.data.slug
    # console.log Template.parentData(5)
    if current_doc
        if doc_field.data and doc_field.data.slug
            current_doc["#{doc_field.data.slug}"]

Template.registerHelper 'page_key_value', (key) -> 
    # doc_field = Template.parentData(2)
    current_doc = Docs.findOne FlowRouter.getParam('doc_id')
    if current_doc
        current_doc["#{@key}"]


Template.registerHelper 'is_dev', () -> Meteor.isDevelopment


Template.left_sidebar.onRendered ->
    @autorun =>
        if @subscriptionsReady()
            Meteor.setTimeout ->
                $('.context.example .ui.left.sidebar')
                    .sidebar({
                        context: $('.context.example .bottom.segment')
                        dimPage: false
                        transition:  'push'
                    })
                    .sidebar('attach events', '.context.example .menu .toggle_left_sidebar.item')
            , 750
            
Template.right_sidebar.onRendered ->
    @autorun =>
        if @subscriptionsReady()
            Meteor.setTimeout ->
                $('.context.example .ui.right.sidebar')
                    .sidebar({
                        context: $('.context.example .bottom.segment')
                        dimPage: false
                        transition:  'push'
                    })
                    .sidebar('attach events', '.toggle_right_sidebar.item')
                    # .sidebar('attach events', '.context.example .menu .toggle_left_sidebar.item')
            , 1500
            
            
