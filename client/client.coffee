$.cloudinary.config
    cloud_name:"facet"

Template.body.events
    'click .toggle_sidebar': -> $('.ui.sidebar').sidebar('toggle')

Template.registerHelper 'is_author', () ->  Meteor.userId() is @author_id

Template.registerHelper 'overdue', () ->
    if @assignment_timestamp
        now = Date.now()
        response = @assignment_timestamp - now
        calc = moment.duration(response).humanize()
        hour_amount = moment.duration(response).asHours()
        if hour_amount<-5 then true else false



Template.registerHelper 'cell_value', () ->
    cell_object = Template.parentData(3)
    @["#{cell_object.key}"]


# Template.registerHelper 'can_edit', () ->  Meteor.userId() is @author_id or 'admin' in Meteor.user().roles

Template.registerHelper 'to_percent', (number) -> (number*100).toFixed()

Template.registerHelper 'databank_docs': ->
    Docs.find { type:Session.get('selected_doc_type') }


Template.registerHelper 'from_now', (input) -> moment(input).fromNow()
Template.registerHelper 'long_format', (input) ->
    if input
        moment(input).format('MMMM Do h:mma')

Template.registerHelper 'delta', () -> Docs.findOne type:'delta'

Template.registerHelper 'is_level_one', () -> @level is 1
Template.registerHelper 'is_level_two', () -> @level is 2
Template.registerHelper 'is_level_three', () -> @level is 3
Template.registerHelper 'is_level_four', () -> @level is 4

Template.registerHelper 'ticket_color_class', () ->
    if @level
        color = switch @level
            when 1 then 'green'
            when 2 then 'yellow'
            when 3 then 'orange'
            when 4 then 'red'

Template.registerHelper 'when', () -> moment(@timestamp).fromNow()
Template.registerHelper 'editing', () -> Template.instance().editing.get()

Template.registerHelper 'my_office', () ->
    if Meteor.user()
        if Meteor.user().office_jpid
            users_office = Docs.findOne
                office_jpid: Meteor.user().office_jpid
                type:'office'
            if users_office
                # console.log users_office
                users_office
        # if user.customer_jpid
        #     customer_doc = Docs.findOne
        #         customer_jpid: user.customer_jpid
        #         type:'customer'
        #     if customer_doc
        #         users_office = Docs.findOne
        #             "ev.MASTER_LICENSEE": customer_doc.ev.MASTER_LICENSEE
        #             type:'office'
        #         users_office
        #     else null
    else null


Template.registerHelper 'is_admin', () ->
    if Meteor.user() and Meteor.user().roles
        'admin' in Meteor.user().roles
Template.registerHelper 'is_dev', () ->
    if Meteor.user() and Meteor.user().roles
        'dev' in Meteor.user().roles
Template.registerHelper 'dev_mode', ()->
    if Meteor.user() and Meteor.user().roles
        'dev' in Meteor.user().roles and Session.get('dev_mode')
Template.registerHelper 'is_eric', ()->
    if Meteor.user()
        'Bda8mRG925DnxTjQC' is Meteor.userId()



Template.registerHelper 'actions', ()->
    delta = Docs.findOne type:'delta'
    local_doc =
        if @data
            Docs.findOne @data.valueOf()
        else
            Docs.findOne @valueOf()
    if local_doc?.type is 'field'
        Docs.find({
            type:'action'
            schema_slugs: $in: ['field']
        }, {sort:{rank:1}}).fetch()
    else
        schema = Docs.findOne
            type:'schema'
            slug:delta.filter_type[0]
        Docs.find({
            type:'action'
            # visible:true
            schema_slugs: $in: [schema.slug]
        }, {sort:{rank:1}}).fetch()


Template.registerHelper 'is_array', ()-> @primative in ['array','multiref']

Template.registerHelper 'full_mode', ()->
    delta = Docs.findOne type:'delta'
    delta.viewing_detail

Template.registerHelper 'expanded', ()->
    delta = Docs.findOne type:'delta'
    delta.expand_id is @_id


Template.registerHelper 'can_add', ()->
    delta = Docs.findOne type:'delta'
    type_key = delta.filter_type[0]
    schema = Docs.findOne
        type:'schema'
        slug:type_key
    if 'dev' in Meteor.user().roles
        true
    else
        my_role = Meteor.user()?.roles?[0]
        if schema and my_role
            if schema.add_roles
                if my_role in schema.add_roles
                    true
                else
                    false
            else
                false
        else
            false


Template.registerHelper 'my_role', ()->
    if Meteor.user() and Meteor.user().roles
        role_slug = Meteor.user().roles[0]
        Docs.findOne
            type:'role'
            slug: role_slug

# Template.registerHelper 'editing_mode', ()->
#     if Meteor.user() and Meteor.user().roles
#         'dev' in Meteor.user().roles and Session.get('editing_mode')



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


Template.registerHelper 'owner', () ->
    Meteor.users.findOne username:@ticket_owner
Template.registerHelper 'secondary', () ->
    Meteor.users.findOne username:@secondary_contact







Template.leftbar.onRendered ->
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
