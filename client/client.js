// import { Meteor } from 'meteor/meteor'
// import { $ } from 'meteor/jquery'
// import { cloudinary } from 'meteor/lepozepo:cloudinary'
import moment from 'moment'

var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };


$.cloudinary.config({
  cloud_name: "facet"
})


Template.body.events({
  'click .toggle_sidebar': ()=> {
    return $('.ui.sidebar').sidebar('toggle')
  }
})

Template.registerHelper('is_editing', ()=> {
  return Session.equals('editing_id', this._id)
})

Template.registerHelper('is_author', ()=> {return Meteor.userId() === this.author_id })

Template.registerHelper('can_edit', ()=> {
  return Meteor.userId() === this.author_id || indexOf.call(Meteor.user().roles, 'admin') >= 0
})

Template.registerHelper('to_percent', function(number) {
  return (number * 100).toFixed()
})

Template.registerHelper('is_closed', ()=> {
  return this.status === 'closed'
})

Template.registerHelper('publish_when', ()=> {
  return moment(this.publish_date).fromNow()
})

Template.registerHelper('reg_format', function(input) {
  return moment(input).format('MMMM Do YYYY, h:mm:ss a')
})

Template.registerHelper('doc', ()=> {
  return Docs.findOne(FlowRouter.getParam('doc_id'))
})

Template.registerHelper('when', ()=> {
  return moment(this.timestamp).fromNow()
})

Template.registerHelper('my_office', ()=> {
  var customer_doc, user, users_office
  user = Meteor.user()
  if (user && user.profile && user.profile.customer_jpid) {
    customer_doc = Docs.findOne({
      "ev.ID": user.profile.customer_jpid,
      type: 'customer'
    })
    if (customer_doc) {
      users_office = Docs.findOne({
        "ev.MASTER_LICENSEE": customer_doc.ev.MASTER_LICENSEE,
        type: 'office'
      })
      return users_office
    } else {
      return null
    }
  }
})

Template.registerHelper('nav_class', ()=> {
  if (Meteor.user() && Meteor.user().roles && indexOf.call(Meteor.user().roles, 'customer') >= 0) {
    return 'nav_bar'
  } else {
    return 'inverted'
  }
})

Template.registerHelper('footer_class', ()=> {
  if (Meteor.user() && Meteor.user().roles && indexOf.call(Meteor.user().roles, 'customer') >= 0) {
    return 'footer_area inverted'
  } else {
    return 'inverted'
  }
})

Template.registerHelper('from_now', function(date) {
  return moment(date).fromNow()
})

Template.registerHelper('formal_when', ()=> { return moment(this.timestamp).format('MMMM Do YYYY, h:mm:ss a') })

Template.registerHelper('is_admin', ()=> {
  if (Meteor.user() && Meteor.user().roles) {
    return indexOf.call(Meteor.user().roles, 'admin') >= 0
  }
})

Template.registerHelper('is_dev', ()=> {
  if (Meteor.user() && Meteor.user().roles) {
    return indexOf.call(Meteor.user().roles, 'dev') >= 0
  }
})

Template.registerHelper('is_officer', ()=> {
  if (Meteor.user() && Meteor.user().roles) {
    return indexOf.call(Meteor.user().roles, 'office') >= 0
  }
})

Template.registerHelper('is_customer', ()=> {
  if (Meteor.user() && Meteor.user().roles) {
    return indexOf.call(Meteor.user().roles, 'customer') >= 0
  }
})

Template.registerHelper('has_user_customer_jpid', ()=> {
  return Meteor.user() && Meteor.user().profile && Meteor.user().profile.customer_jpid
})

Template.registerHelper('is_dev_env', ()=> {
  return Meteor.isDevelopment
})

Template.registerHelper('key_value', function(key) {
  var current_doc, doc_field
  doc_field = Template.parentData(2)
  current_doc = Docs.findOne(FlowRouter.getParam('doc_id'))
  if (this.key) {
    return current_doc["" + this.key]
  }
})

Template.registerHelper('page_key_value', function(key) {
  var current_doc
  current_doc = Docs.findOne(FlowRouter.getParam('doc_id'))
  if (current_doc) {
    return current_doc["" + key]
  }
})

Template.registerHelper('profile_key_value', ()=> {
  var current_user
  current_user = Meteor.users.findOne(FlowRouter.getParam('user_id'))
  if (current_user) {
    return current_user.profile["" + this.key]
  }
})

Template.left_sidebar.onRendered(()=> {
  return Meteor.setTimeout(()=> {
    return $('.context.example .ui.left.sidebar').sidebar({
      context: $('.context.example .bottom.segment'),
      dimPage: false,
      transition: 'push'
    }).sidebar('attach events', '.context.example .menu .toggle_left_sidebar.item')
  }, 750)
})
