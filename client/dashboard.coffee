Template.dashboard.onCreated ->
    @autorun -> Meteor.subscribe 'my_blocks'

Template.dashboard.helpers
    my_blocks: ->
        Docs.find
            type:'block'
            block_type: 'dashboard'
            author_id: Meteor.userId()


Template.dashboard.events
    'click .add_block': ->
        # console.log 'hi'
        Docs.insert
            type:'block'
            block_type: 'dashboard'



Template.customer_menu.events
    'click .log_ticket': (e,t)->
        Meteor.call 'log_ticket', (err,res)->
            if err then console.error err
            else
                # console.log res
                FlowRouter.go "/p/submit_ticket?doc_id=#{res}"


Template.dashboard_office_contacts_list.onCreated ->
    @autorun -> Meteor.subscribe 'my_office_contacts'

Template.dashboard_office_contacts_list.helpers
    office_contacts: ->
        found = Meteor.users.find {
            # published:true
            # "office_name": customer_doc.ev.MASTER_LICENSEE
        }, limit:100
        found

        # user = Meteor.user()
        # if user and user.customer_jpid
        #     customer_doc = Docs.findOne
        #         customer_jpid: user.customer_jpid
        #         type:'customer'
        #         # grandparent office
        #     if customer_doc
        #         found = Meteor.users.find {
        #             published:true
        #             # "office_name": customer_doc.ev.MASTER_LICENSEE
        #         }, limit:100
        #         console.log found.count(), 'found'




Template.dashboard_service_list.onRendered ->
    Meteor.setTimeout ->
        $('.service_popup').popup({
            inline: false
            hoverable:true
        })
    , 800

Template.dashboard_service_list.onCreated ->
    @autorun -> Meteor.subscribe 'type','service'
Template.dashboard_service_list.helpers
    services_offered: ->
        users_office = Meteor.user().users_office()
        if users_office
            Docs.find
                type:'service'
                slug: $in: users_office.services

Template.dashboard_service_list.events
    # 'click .service_popup': (e,t)->
    'click .request_service': ->
        current_customer_jpid = Meteor.user().customer_jpid
        new_request_id =
            Docs.insert
                type:'service_request'
                service_id:@_id
                service_title:@title
                service_slug:@slug
                customer_jpid:current_customer_jpid
        FlowRouter.go "/edit/#{new_request_id}"
        Meteor.call 'calculate_request_count', @_id



Template.dashboard_office_messages.onCreated ->
    @autorun -> Meteor.subscribe 'my_office_messages'
Template.dashboard_office_messages.helpers
    office_messages: ->
        Docs.find
            type:'office_message'



