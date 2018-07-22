
Template.users.helpers({
  settings: function() {
    return {
      collection: 'users',
      rowsPerPage: 10,
      showFilter: true,
      showRowCount: true,
      fields: [
        {
          key: 'username',
          label: 'Username'
        }, {
          key: 'profile.first_name',
          label: 'First Name'
        }, {
          key: 'profile.last_name',
          label: 'Last Name'
        }, {
          key: 'ev.JOB_TITLE',
          label: 'Job Title'
        }, {
          key: 'ev.WORK_TELEPHONE',
          label: 'Work Tel'
        }, {
          key: 'emails[0].address',
          label: 'Email'
        }, {
          key: 'profile.office_name',
          label: 'Email'
        }, {
          key: '',
          label: 'View',
          tmpl: Template.view_user_button
        }
      ]
    }
  }
})

Template.users.events({
  'click .sync_ev_users': function() {
    return Meteor.call('sync_ev_users', function(err, res) {
      if (err) {
        return console.error(err)
      }
    })
  }
})

Template.users.helpers({
  selector: function() {
    return {
      type: "user"
    }
  }
})
