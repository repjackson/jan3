$.cloudinary.config
    cloud_name:"facet"

FlowRouter.notFound =
    action: ->
        BlazeLayout.render 'layout', 
            main: 'not_found'


FlowRouter.route('/', {
    triggersEnter: [(context, redirect) ->
        user = Meteor.user()
        
        if user
            if user.roles 
                if 'customer' in user.roles
                    redirect '/p/customer_dashboard' 
                else if 'admin' in user.roles
                    redirect '/p/admin' 
                else if 'office' in user.roles
                    redirect "/p/office_incidents/#{user.office_jpid}" 
        else
            redirect '/login' 
    ]
})

# Meteor.startup( () =>
#     GoogleMaps.load
#         key: 'AIzaSyAK_vkvxDH5vsqGkd0Qn-dDmq-rShTA7UA',
#         libraries: 'places'
# )


Session.setDefault('query',null)
Session.setDefault('dev_mode',false)
Session.setDefault('editing_mode',false)

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
    Session.equals 'editing_id', @_id

Template.registerHelper 'is_author', () ->  Meteor.userId() is @author_id

Template.registerHelper 'overdue', () -> 
    if @assignment_timestamp
        now = Date.now()
        response = @assignment_timestamp - now
        calc = moment.duration(response).humanize()
        hour_amount = moment.duration(response).asHours()
        if hour_amount<-5 then true else false


# Template.registerHelper 'unread_count', () ->  
#     found_unread_count_stat = Stats.findOne({
#         doc_type:'message'
#         stat_type:'unread'
#         username:Meteor.user().username
#     })
#     if found_unread_count_stat
#         found_unread_count_stat.amount
        
        
        
Template.registerHelper 'my_office_link', () ->  
    user = Meteor.user()
    if user
        if user.office_jpid
            # users_office = Docs.findOne
            #     "ev.ID": user.office_jpid
            #     type:'office'
            # users_office
            return "/p/office_incidents/#{user.office_jpid}"

Template.registerHelper 'can_edit', () ->  Meteor.userId() is @author_id or 'admin' in Meteor.user().roles

Template.registerHelper 'to_percent', (number) -> (number*100).toFixed()         
Template.registerHelper 'is_closed', () -> @status is 'closed'

Template.registerHelper 'databank_docs': ->  
    Docs.find { type:Session.get('selected_doc_type')}


Template.registerHelper 'from_now', (input) -> moment(input).fromNow()
Template.registerHelper 'long_format', (input) -> moment(input).format('MMMM Do h:mma')

Template.registerHelper 'doc', () -> Docs.findOne FlowRouter.getQueryParam('doc_id')


Template.registerHelper 'when', () -> moment(@timestamp).fromNow()

Template.registerHelper 'my_office', () -> 
    user = Meteor.user()
    if user
        if user.office_jpid
            users_office = Docs.findOne
                "ev.ID": user.office_jpid
                type:'office'
            users_office
        # if user.customer_jpid
        #     customer_doc = Docs.findOne
        #         "ev.ID": user.customer_jpid
        #         type:'customer'
        #     if customer_doc
        #         users_office = Docs.findOne
        #             "ev.MASTER_LICENSEE": customer_doc.ev.MASTER_LICENSEE
        #             type:'office'
        #         users_office
        #     else null
    else null


Template.registerHelper 'is_current_route', (name) -> 
    if FlowRouter.current().route.name is name then 'active' else ''
    
    
Template.registerHelper 'is_admin', () -> 
    if Meteor.user() and Meteor.user().roles
        'admin' in Meteor.user().roles
Template.registerHelper 'is_dev', () -> 
    if Meteor.user() and Meteor.user().roles
        'dev' in Meteor.user().roles
Template.registerHelper 'dev_mode', ()->
    if Meteor.user() and Meteor.user().roles
        'dev' in Meteor.user().roles and Session.get('dev_mode')
        
        
Template.registerHelper 'editing_mode', ()->
    if Meteor.user() and Meteor.user().roles
        'dev' in Meteor.user().roles and Session.get('editing_mode')
        
        
        
Template.registerHelper 'is_editor', () -> 
    if Meteor.user() and Meteor.user().roles
        'admin' in Meteor.user().roles
Template.registerHelper 'is_office', () -> 
    if Meteor.user() and Meteor.user().roles
        'office' in Meteor.user().roles
Template.registerHelper 'is_customer', () -> 
    if Meteor.user() and Meteor.user().roles
        'customer' in Meteor.user().roles
        
Template.registerHelper 'user_is_customer', () -> @roles and 'customer' in @roles
Template.registerHelper 'user_is_office', () -> @roles and 'office' in @roles
        
Template.registerHelper 'has_user_customer_jpid', () -> 
    Meteor.user() and Meteor.user().customer_jpid

Template.registerHelper 'is_dev_env', () -> Meteor.isDevelopment


Template.registerHelper 'block_field_value', ->
    sla_setting = Template.parentData(0)
    field_key = Template.parentData(3).key
    value = sla_setting["#{field_key}"]



# Meteor.startup ->
#     # HTTP.call('get',"https://avalon.extraview.net/jan-pro/ExtraView/ev_api.action?user_id=zpeckham&password=jpi19&statevar=get_roles", (err,res)->
#     HTTP.call('get',"http://www.npr.org/rss/podcast.php?id=510307", (err,res)->
#         else
#     )
# Template.registerHelper 'slug_value', () -> 
#     doc_field = Template.parentData(2)
#     current_doc = Template.parentData(3)
#     current_doc["#{@slug}"]

Template.registerHelper 'page_key_value', () -> 
    # doc_field = Template.parentData(2)
    current_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
    if current_doc
        current_doc["#{@key}"]
        
Template.registerHelper 'page_slug_key_value', () -> 
    # doc_field = Template.parentData(2)
    page = Docs.findOne 
        type:'page'
        slug:FlowRouter.getParam('page_slug')
    if page
        page["#{@key}"]
        
        
Template.registerHelper 'page_jpid_key_value', () -> 
    # doc_field = Template.parentData(2)
    page = Docs.findOne 
        "ev.ID":FlowRouter.getParam('jpid')
    if page
        page["#{@key}"]
        
        
        
        
Template.registerHelper 'active_route', (slug) -> 
    if FlowRouter.getParam('page_slug') is slug then 'active' else ''
        


Template.registerHelper 'profile_key_value', () -> 
    # doc_field = Template.parentData(2)
    current_user = Meteor.users.findOne FlowRouter.getParam('user_id')
    if current_user
        current_user.profile["#{@key}"]
        
Template.registerHelper 'user_key_value', () -> 
    # doc_field = Template.parentData(2)
    current_user = Meteor.users.findOne FlowRouter.getParam('user_id')
    if current_user
        current_user["#{@key}"]
        
# Template.registerHelper 'user_key_value', () -> 
#     # doc_field = Template.parentData(2)
#     current_user = Meteor.users.findOne FlowRouter.getParam('user_id')
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
            