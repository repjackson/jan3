Template.left_sidebar.events({
  'click #logout': function(e, t) {
    e.preventDefault()
    return Meteor.logout()
  }
})

Template.nav.events({
  'click #logout': function(e, t) {
    e.preventDefault()
    return Meteor.logout()
  }
})

Template.nav.onCreated(function() {
  this.autorun(function() {
    return Meteor.subscribe('my_customer_account')
  })
  this.autorun(function() {
    return Meteor.subscribe('my_franchisee')
  })
  this.autorun(function() {
    return Meteor.subscribe('me')
  })
  return this.autorun(function() {
    return Meteor.subscribe('my_office')
  })
})
