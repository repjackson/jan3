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

Template.registerHelper 'to_percent', (number) -> (number*100).toFixed()         

Template.registerHelper 'publish_when', () -> moment(@publish_date).fromNow()

Template.registerHelper 'doc', () -> Docs.findOne FlowRouter.getParam('doc_id')

Template.registerHelper 'when', () -> moment(@timestamp).fromNow()

Template.registerHelper 'formal_when', () -> moment(@timestamp).format('MMMM Do YYYY, h:mm:ss a')


Template.registerHelper 'key_value', () -> 
    current_doc = Template.parentData(1)
    if current_doc
        current_doc["#{@key}"]


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
            
            
