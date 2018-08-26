$.cloudinary.config
    cloud_name:"facet"

FlowRouter.notFound =
    action: ->
        BlazeLayout.render 'layout', 
            main: 'not_found'
# Meteor.startup( () =>
#     GoogleMaps.load
#         key: 'AIzaSyAK_vkvxDH5vsqGkd0Qn-dDmq-rShTA7UA',
#         libraries: 'places'
# )


Session.setDefault('query',null)
Session.setDefault('sort_direction','-1')
Session.setDefault('sort_key','timestamp')
Session.setDefault('page_size',10)
Session.setDefault('skip',0)
Session.setDefault('current_page_number',1)

Bert.defaults =
    hideDelay: 2000
    #   Accepts: a number in milliseconds.
    style: 'growl-bottom-right'
    # Accepts: fixed-top, fixed-bottom, growl-top-left,   growl-top-right,
    # growl-bottom-left, growl-bottom-right.
    type: 'default'
#   // Accepts: default, success, info, warning, danger.


Template.body.events
    'click .toggle_sidebar': -> $('.ui.sidebar').sidebar('toggle')

Template.registerHelper 'is_editing', () -> 
    # console.log 'this', @
    Session.equals 'editing_id', @_id

Template.registerHelper 'is_author', () ->  Meteor.userId() is @author_id

Template.registerHelper 'my_office_link', () ->  
    user = Meteor.user()
    # console.log 'franch_doc', franch_doc
    if user and user.profile 
        if user.office_jpid
            users_office = Docs.findOne
                "ev.ID": user.office_jpid
                type:'office'
            # console.log users_office
            users_office
            return "/office/#{users_office._id}"

Template.registerHelper 'can_edit', () ->  Meteor.userId() is @author_id or 'admin' in Meteor.user().roles

Template.registerHelper 'to_percent', (number) -> (number*100).toFixed()         
Template.registerHelper 'is_closed', () -> @status is 'closed'

Template.registerHelper 'publish_when', () -> moment(@publish_date).fromNow()
# Template.registerHelper 'reg_format', (input) -> moment(input).format('MMMM Do YYYY, h:mm:ss a')
Template.registerHelper 'reg_format', (input) -> moment(input).format('MMMM Do h:mma')

Template.registerHelper 'doc', () -> Docs.findOne FlowRouter.getParam('doc_id')

Template.registerHelper 'when', () -> moment(@timestamp).fromNow()

Template.registerHelper 'my_office', () -> 
    user = Meteor.user()
    # console.log 'franch_doc', franch_doc
    if user and user.profile 
        if user.office_jpid
            users_office = Docs.findOne
                "ev.ID": user.office_jpid
                type:'office'
            # console.log users_office
            users_office
        # if user.customer_jpid
        #     customer_doc = Docs.findOne
        #         "ev.ID": user.customer_jpid
        #         type:'customer'
        #     console.log customer_doc
        #     if customer_doc
        #         users_office = Docs.findOne
        #             "ev.MASTER_LICENSEE": customer_doc.ev.MASTER_LICENSEE
        #             type:'office'
        #         console.log users_office
        #         users_office
        #     else null
    else null

Template.registerHelper 'from_now', (date) -> moment(date).fromNow()

Template.registerHelper 'formal_when', () -> moment(@timestamp).format('MMMM Do YYYY, h:mm:ss a')

Template.registerHelper 'is_current_route', (name) -> 
    if FlowRouter.current().route.name is name then 'active' else ''
    
    
Template.registerHelper 'tag_class', () -> 
    if selected_tags.array() and @valueOf() in selected_tags.array() then 'blue' else 'basic'
    
    
Template.registerHelper 'is_admin', () -> 
    if Meteor.user() and Meteor.user().roles
        'admin' in Meteor.user().roles
Template.registerHelper 'is_dev', () -> 
    if Meteor.user() and Meteor.user().roles
        'dev' in Meteor.user().roles
Template.registerHelper 'is_office', () -> 
    if Meteor.user() and Meteor.user().roles
        'office' in Meteor.user().roles
Template.registerHelper 'is_customer', () -> 
    if Meteor.user() and Meteor.user().roles
        'customer' in Meteor.user().roles
        
Template.registerHelper 'user_is_customer', () -> @roles and 'customer' in @roles
Template.registerHelper 'user_is_office', () -> @roles and 'office' in @roles
        
Template.registerHelper 'has_user_customer_jpid', () -> 
    Meteor.user() and Meteor.user() and Meteor.user().customer_jpid

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
    current_doc = Docs.findOne FlowRouter.getParam('doc_id')
    # console.log @key
    # console.log Template.parentData(1)
    # console.log Template.parentData(2)
    # console.log Template.parentData(3)
    # console.log Template.parentData(4)
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
        
# Template.registerHelper 'user_key_value', () -> 
#     # doc_field = Template.parentData(2)
#     current_user = Meteor.users.findOne FlowRouter.getParam('user_id')
#     console.log Template.parentData()
#     Meteor.users. 
#         current_user["#{@key}"]
        
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
            
    # if @subscriptionsReady()
    #         Meteor.setTimeout ->
    #             $('.context.example .ui.right.sidebar')
    #                 .sidebar({
    #                     context: $('.context.example .bottom.segment')
    #                     dimPage: false
    #                     transition:  'push'
    #                 })
    #                 .sidebar('attach events', '.toggle_right_sidebar.item')
    #                 # .sidebar('attach events', '.context.example .menu .toggle_left_sidebar.item')
    #         , 1500
            