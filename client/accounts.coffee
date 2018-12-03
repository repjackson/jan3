Template.login.events
    'click .login': (e,t)->
        # e.preventDefault()
        username = $('.username').val()
        password = $('.password').val()
        Meteor.loginWithPassword username, password, (err,res)->
            if err
                alert err
            # else
            #     console.log 'yea'

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
