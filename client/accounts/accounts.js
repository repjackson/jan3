import {$} from 'meteor/jquery'

Template.login.events({
  'blur .username': (e,t)=>{
    const username = $('.username').val()
    console.log(username)
    Session.set('username',username)
  },
  'blur .password': (e,t)=>{
    const password = $('.password').val()
    console.log(password)
    Session.set('password',password)
  },
  'click .login': function(e, t) {
    var login, password
    e.preventDefault()
    login = $('.username').val()
    password = $('.password').val()
    return Meteor.loginWithPassword(login, password, function(err, res) {
      if (err) {
        return console.log(err)
      } else {
        Bert.alert("Logged in " + (Meteor.user().username) + ". Redirecting to dashboard.", 'success', 'growl-top-right')
        return FlowRouter.go('/')
      }
    })
  },
  'keyup .password': function(e, t) {
    var login, password
    if (e.which === 13) {
      e.preventDefault()
      login = $('.username').val()
      password = $('.password').val()
      return Meteor.loginWithPassword(login, password, function(err, res) {
        if (err) {
          return console.log(err)
        } else {
          Bert.alert("Logged in " + (Meteor.user().username) + ". Redirecting to dashboard.", 'success', 'growl-top-right')
          return FlowRouter.go('/')
        }
      })
    }
  },
  'click #login_demo_admin': function() {
    return Meteor.loginWithPassword('admin', 'adminpassword', function(err, res) {
      if (err) {
        return console.error(err)
      } else {
        return console.log(res)
      }
    })
  },
  'click #login_demo_office': function() {
    return Meteor.loginWithPassword('office', 'officepassword', function(err, res) {
      if (err) {
        return console.error(err)
      } else {
        return console.log(res)
      }
    })
  },
  'click #login_demo_customer': function() {
    return Meteor.loginWithPassword('customer', 'customerpassword', function(err, res) {
      if (err) {
        return console.error(err)
      } else {
        return console.log(res)
      }
    })
  }
})
Template.login.helpers({
  can_login: function() {
    const username_value = Session.get('username')
    const password_value = Session.get('password')
    // const customer_jpid_value = $('.customer_jpid').val()
    if ((username_value>0) && (password_value>0)) {
      return true
    } else {
      return false
    }
  }
})

Template.register_customer.helpers({
  user_found: function() {
    return Session.get('username_found')
  },
  passwords_match: function() {
    var password_one, password_two
    password_one = Session.get('password_one')
    password_two = Session.get('password_two')
    if (password_one.length && password_one === password_two) {
      return true
    } else {
      return false
    }
  },
  can_register_customer: function() {
    var customer_jpid, email, login, password_one, password_two
    login = $('.username').val()
    email = $('.email').val()
    customer_jpid = $('.customer_jpid').val()
    password_one = Session.get('password_one')
    password_two = Session.get('password_two')
    if (login && password && customer_jpid && password_one && password_two) {
      return true
    } else {
      return false
    }
  }
})

Template.register_customer.events({
  'click .login': function(e, t) {
    var login, password
    e.preventDefault()
    login = $('.username').val()
    password = $('.password').val()
    return Meteor.loginWithPassword(login, password, function(err, res) {
      if (err) {
        return console.log(err)
      } else {
        Bert.alert("Logged in " + (Meteor.user().username) + ". Redirecting to dashboard.", 'success', 'growl-top-right')
        return FlowRouter.go('/')
      }
    })
  },
  'keyup .username': function(e, t) {
    var login, password
    if (e.which === 13) {
      e.preventDefault()
      login = $('.username').val()
      password = $('.password').val()
      return Meteor.loginWithPassword(login, password, function(err, res) {
        if (err) {
          return console.log(err)
        } else {
          Bert.alert("Logged in " + (Meteor.user().username) + ". Redirecting to dashboard.", 'success', 'growl-top-right')
          return FlowRouter.go('/')
        }
      })
    }
  },
  'blur .username': function(e, t) {
    var username
    username = $('.username').val()
    return console.log(username)
  },
  'keyup .username': function(e, t) {
    var username
    e.preventDefault()
    username = $('.username').val()
    return Meteor.call('check_username', username, function(err, res) {
      if (err) {
        return console.error(err)
      } else {
        if (res) {
          return Session.set('username_found', res)
        } else {
          return Session.set('username_found', null)
        }
      }
    })
  },
  'keyup .email': function(e, t) {
    var email
    e.preventDefault()
    email = $('.email').val()
    console.log(email)
    return Meteor.call('check_email', email, function(err, res) {
      if (err) {
        return console.error(err)
      } else {
        if (res) {
          return Session.set('email_found', res)
        } else {
          return Session.set('email_found', null)
        }
      }
    })
  },
  'keyup .password_one': function(e, t) {
    var password_one
    e.preventDefault()
    password_one = $('.password_one').val()
    Session.set('password_one', password_one)
    return console.log(password_one)
  },
  'keyup .password_two': function(e, t) {
    var password_two
    e.preventDefault()
    password_two = $('.password_two').val()
    Session.set('password_two', password_two)
    return console.log(password_two)
  }
})