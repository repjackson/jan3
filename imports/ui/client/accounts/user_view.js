Template.user_view.onCreated(function() {
  return this.autorun(function() {
    return Meteor.subscribe('user', FlowRouter.getParam('username'))
  })
})

Template.user_view.helpers({
  user: function() {
    return Meteor.users.findOne({
      username: FlowRouter.getParam('username')
    })
  },
  is_user: ()=>{
    const user_boolean = Meteor.user().username == FlowRouter.getParam('username')
    console.log(user_boolean)
    return user_boolean
    
  }
})

Template.user_view.events({
  'click .get_user_info': function() {
    return Meteor.call('get_user_info', FlowRouter.getParam('username'), function(err, res) {
      if (err) {
        return Bert.alert("" + err.reason, 'danger', 'growl-top-right')
      }
    })
  }
})
