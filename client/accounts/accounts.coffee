Template.login.events
    'click .login': (e,t)->
        # e.preventDefault()
        console.log 'start'
        username = $('.username').val()
        password = $('.password').val()
        Meteor.loginWithPassword username, password, (err,res)->
            if err
                alert err
            else
                console.log 'yea'

    'keyup .username, keyup .password': (e,t)->
        if e.which is 13 #enter
            e.preventDefault()
            username = $('.username').val()
            password = $('.password').val()
            Meteor.loginWithPassword username, password, (err,res)->
                if err
                    alert err


    'click #login_demo_admin': ->
        Meteor.loginWithPassword 'demo_admin', 'demoadminpassword', (err,res)->

    'click #login_demo_office': ->
        Meteor.loginWithPassword 'demo_office', 'demoofficepassword', (err,res)->

    'click #login_demo_customer': ->
        Meteor.loginWithPassword 'demo_customer', 'democustomerpassword', (err,res)->


Template.login.helpers
    login_button_class: ->
        if Meteor.loggingIn()
            'loading disabled'
        else if Meteor.user()
            ''

    demo_class: ->
        if Meteor.loggingIn()
            'disabled'
        # else if Meteor.user()
        #     'disabled'



Template.register_customer.onCreated ->
    @autorun =>  Meteor.subscribe 'doc_by_jpid', Session.get('customer_jpid')
    @autorun =>  Meteor.subscribe 'doc_by_jpid', Session.get('office_jpid')
    @registering = new ReactiveVar false
    @can_register = new ReactiveVar false

Template.register_customer.onRendered ->
    Session.setDefault 'customer_jpid', null
    Session.setDefault 'account_selected', false

Template.register_customer.helpers
    register_button_class: ->
        if Template.instance().registering.get() is true then 'loading disabled' else ''

    customer_doc: ->
        doc =
            Docs.findOne
                type:'customer'
                customer_jpid: Session.get('customer_jpid')
        doc

    office_doc: ->
        doc =
            Docs.findOne
                type:'office'
                office_jpid: Session.get('office_jpid')
        doc

    user_found: -> Session.get 'username_found'
    jpid_lookup_status: -> Session.get 'jpid_lookup_status'
    account_selected:  -> Session.get 'account_selected'

    session_customer_jpid: -> parseInt(Session.get('customer_jpid'))
    session_office_jpid: -> parseInt(Session.get('office_jpid'))

    passwords_match: ->
        password_one = Session.get 'password_one'
        password_two = Session.get 'password_two'
        if password_one.length and password_one is password_two then true else false

    can_register: ->
        Template.instance().can_register.get()


Template.register_customer.events
    'click #register': (e,t)->
        username = $('#username').val()
        password = $('#password').val()
        email = $('#email').val()
        # office_id = $('#office_id').val()
        customer_jpid = Session.get 'customer_jpid'
        franchisee_jpid = Session.get 'franchisee_jpid'
        office_jpid = Session.get 'office_jpid'

        options = {}

        if username
            options.username = username
        if password
            options.password = password
        if email
            options.email = email
        options.customer_jpid = customer_jpid
        options.franchisee_jpid = franchisee_jpid
        options.office_jpid = office_jpid
        options.roles = ['customer']


        Accounts.createUser(options, (err,res)=>
            if err
                alert err
            else
                Docs.insert
                    type:'message'
                    username:options.username
                    text: "#{options.username} Customer registered to JPID #{options.customer_jpid}"
                # if current_role is 'customer'
                #     Meteor.call 'refresh_customer_jpids', user.username
                # if current_role is 'office'
                #     office_doc =
                #         Docs.findOne
                #             type:'office'
                #             office_jpid: office_jpid
        )

    'keyup #username': (e,t)->
        username = $('#username').val().trim()
        Session.set 'session_username', username
        Meteor.call 'check_username', username, (err, res)->
            if err then console.error err
            else
                if res
                    Session.set 'username_found', true
                else
                    Session.set 'username_found', false

    'keyup #email': (e,t)->
        email = $('#email').val()
        if email.length > 0
            Session.set 'session_email', email
        Meteor.call 'check_email', email, (err, res)->
            if err then console.error err
            else
                if res
                    Session.set 'email_found', res
                else
                    Session.set 'email_found', null

    'keyup #password_one': (e,t)->
        password_one = $('#password_one').val()
        Session.set 'session_password_one', password_one

    'keyup #password_two': (e,t)->
        password_two = $('#password_two').val()
        Session.set 'session_password_two', password_one

    'keyup #customer_jpid': (e,t)->
        customer_jpid = $('#customer_jpid').val().trim()
        Meteor.call 'find_customer_by_jpid', customer_jpid, (err,res)->
            if err
                Session.set 'jpid_lookup_status', err.error
            else
                Session.set 'account_selected', true
                Session.set 'customer_jpid', res.ev.ID
                Session.set 'jpid_lookup_status', "Found JPID #{customer_jpid}."
                t.can_register.set true
                Meteor.call 'find_franchisee_from_customer_jpid', customer_jpid, (err,res)=>
                    if err then console.error err
                    else
                        if res and res.ev
                            Session.set 'franchisee_jpid', res.ev.ID
                Meteor.call 'find_office_from_customer_jpid', customer_jpid, (err,res)=>
                    if err then console.error err
                    else
                        Session.set 'office_jpid', res.ev.ID
        found_customer_doc =
            Docs.findOne
                type:'customer'
                "ev.ID": customer_jpid

        if found_customer_doc
        else
            Session.set 'account_selected', false
            t.can_register.set false


Template.register_office.onCreated ->
    @autorun =>  Meteor.subscribe 'doc_by_jpid', Session.get('office_jpid')

Template.register_office.onRendered ->
    Session.setDefault 'account_selected', false

Template.register_office.helpers
    user_found: -> Session.get 'username_found'
    session_office_jpid: -> Session.get 'office_jpid'
    office_doc: -> Docs.findOne(type:'office')
    jpid_lookup_status: -> Session.get 'jpid_lookup_status'
    account_selected:  -> Session.get 'account_selected'
    passwords_match: ->
        password_one = Session.get 'password_one'
        password_two = Session.get 'password_two'
        if password_one.length and password_one is password_two then true else false
    can_submit: ->
        true
        # # password_two = Session.get 'password_two'
        # session_customer_jpid = Session.get 'customer_jpid'
        # if Session.get('session_username') and Session.get('session_password_one') and Session.get('session_email') and Session.get('session_customer_jpid') then true else false

Template.register_office.events
    'click #register_office': (e,t)->
        username = $('#username').val()
        password = $('#password').val()
        email = $('#email').val()
        office_jpid = parseInt Session.get('office_jpid')


        options = {}

        if username
            options.username = username
        if password
            options.password = password
        if email
            options.email = email
        if office_jpid
            options.office_jpid = office_jpid
            options.roles = ['office']


        console.dir options

        office_doc =
            Docs.findOne
                type:'office'
                office_jpid: office_jpid
        Accounts.createUser(options, (err,res)=>
            if err
                alert err
        )

    'keyup #username': (e,t)->
        username = $('#username').val()
        Session.set 'session_username', username
        Meteor.call 'check_username', username, (err, res)->
            if err then console.error err
            else
                if res
                    Session.set 'username_found', true
                else
                    Session.set 'username_found', false


    'keyup #email': (e,t)->
        email = $('#email').val()
        if email.length > 0
            Session.set 'session_email', email
        Meteor.call 'check_email', email, (err, res)->
            if err then console.error err
            else
                if res
                    Session.set 'email_found', res
                else
                    Session.set 'email_found', null

    'keyup #password_one': (e,t)->
        password_one = $('#password_one').val()
        Session.set 'session_password_one', password_one

    'keyup #password_two': (e,t)->
        password_two = $('#password_two').val()
        Session.set 'session_password_two', password_one


    'keyup #office_jpid': (e,t)->
        office_jpid = parseInt($('#office_jpid').val().trim())
        Session.set 'office_jpid', office_jpid
        found_office_doc =
            Docs.findOne
                type:'office'
                # office_jpid: office_jpid

        if found_office_doc
            Session.set 'account_selected', true
        else
            Session.set 'account_selected', false
        # Meteor.call 'check_password_two', password_two, (err, res)->
        #     if err then console.error err
        #     else
        #         if res
        #             Session.set 'email_found', res
        #         else
        #             Session.set 'email_found', null

