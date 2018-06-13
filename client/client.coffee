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
Template.registerHelper 'is_closed', () -> @status is 'closed'

Template.registerHelper 'publish_when', () -> moment(@publish_date).fromNow()
Template.registerHelper 'reg_format', (input) -> moment(input).format('MMMM Do YYYY, h:mm:ss a')

Template.registerHelper 'doc', () -> Docs.findOne FlowRouter.getParam('doc_id')

Template.registerHelper 'when', () -> moment(@timestamp).fromNow()

Template.registerHelper 'from_now', (date) -> moment(date).fromNow()

Template.registerHelper 'formal_when', () -> moment(@timestamp).format('MMMM Do YYYY, h:mm:ss a')

Template.registerHelper 'is_admin', () -> 
    if Meteor.user()
        'admin' in Meteor.user().roles
Template.registerHelper 'is_dev', () -> 
    if Meteor.user() and Meteor.user().roles
        'dev' in Meteor.user().roles

Template.registerHelper 'is_dev_env', () -> Meteor.isDevelopment

# Meteor.startup ->
#     # HTTP.call('get',"https://avalon.extraview.net/jan-pro/ExtraView/ev_api.action?user_id=zpeckham&password=jpi19&statevar=get_roles", (err,res)->
#     HTTP.call('get',"http://www.npr.org/rss/podcast.php?id=510307", (err,res)->
#         if err then console.log 'ERROR', err
#         else
#             console.log res
#     )
Template.registerHelper 'key_value', (key) -> 
    doc_field = Template.parentData(2)
    current_doc = Template.parentData(5)
    # console.log @key
    # console.log Template.parentData(5)
    if @key
        current_doc["#{@key}"]

Template.registerHelper 'page_key_value', (key) -> 
    # doc_field = Template.parentData(2)
    current_doc = Docs.findOne FlowRouter.getParam('doc_id')
    if current_doc
        current_doc["#{key}"]


Template.registerHelper 'profile_key_value', () -> 
    # doc_field = Template.parentData(2)
    current_user = Meteor.users.findOne FlowRouter.getParam('user_id')
    if current_user
        current_user.profile["#{@key}"]
        
        




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
            
            
