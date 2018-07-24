Template.history.helpers({
  settings: function() {
    return {
      collection: 'search_history_docs',
      rowsPerPage: 10,
      showFilter: true,
      showRowCount: true,
      fields: [
        {
          key: 'ev.ID',
          label: 'JPID'
        }, {
          key: 'ev.TIMESTAMP',
          label: 'EV Timestamp'
        }, {
          key: 'ev.FRANCHISEE',
          label: 'Franchisee'
        }, {
          key: 'ev.CUSTOMER',
          label: 'Customer'
        }, {
          key: 'ev.FRANCH_EMAIL',
          label: 'Email'
        }, {
          key: 'ev.FRANCH_NAME',
          label: 'Short Name'
        }, {
          key: 'ev.AREA',
          label: 'Area'
        }, {
          key: 'ev.MASTER_LICENSEE',
          label: 'Office'
        }, {
          key: '',
          label: 'View',
          tmpl: Template.view_button
        }
      ]
    }
  }
})

Template.history.events({
  'click .refresh_history': function() {
    return Meteor.call('get_history', function(err, res) {
      if (err) {
        return console.error(err)
      }
    })
  },
  'click .run_timestamp_search': function() {
    return Meteor.call('search_ev', function(err, res) {
      if (err) {
        return console.error(err)
      }
    })
  }
})


Template.jpids.onCreated(function() {
  return this.autorun((function(_this) {
    return function() {
      return Meteor.subscribe('type', 'jpid')
    }
  })(this))
})

Template.jpids.helpers({
  settings: function() {
    return {
      collection: 'jpids',
      rowsPerPage: 10,
      showFilter: true,
      showRowCount: true,
      fields: [
        {
          key: 'ev.ID',
          label: 'JPID'
        }, {
          key: 'ev.FRANCHISEE',
          label: 'Franchisee'
        }, {
          key: 'ev.CUSTOMER',
          label: 'Customer'
        }, {
          key: 'ev.FRANCH_EMAIL',
          label: 'Email'
        }, {
          key: 'ev.FRANCH_NAME',
          label: 'Short Name'
        }, {
          key: 'ev.AREA',
          label: 'Area'
        }, {
          key: 'ev.MASTER_LICENSEE',
          label: 'Office'
        }, {
          key: '',
          label: 'View',
          tmpl: Template.view_button
        }
      ]
    }
  }
})

Template.jpids.events({
  'click .get_jp_id': function() {
    return Meteor.call('get_jp_id', function(err, res) {
      if (err) {
        return console.error(err)
      }
    })
  },
  'keyup #jp_lookup': function(e, t) {
    var val
    e.preventDefault()
    val = $('#jp_lookup').val().trim()
    if (e.which === 13) {
      if (val.length !== 0) {
        return Meteor.call('get_jp_id', val.toString(), (function(_this) {
          return function(err, res) {
            if (err) {
              Bert.alert("" + err.reason, 'danger', 'growl-top-right')
            } else {
              Bert.alert("Added JP ID " + val, 'success', 'growl-top-right')
            }
            return $('#jp_lookup').val('')
          }
        })(this))
      }
    }
  }
})

Template.jpid_view.events({
  'click .refresh_jpid': function(e, t) {
    var doc
    doc = Docs.findOne(FlowRouter.getParam('doc_id'))
    return Meteor.call('get_jp_id', doc.jpid, (function(_this) {
      return function(err, res) {
        if (err) {
          return Bert.alert("" + err.reason, 'danger', 'growl-top-right')
        } else {
          return Bert.alert("Updated JP ID " + doc.jpid, 'success', 'growl-top-right')
        }
      }
    })(this))
  }
})

Template.jpids.events({
  'keyup #ev_search': function(e, t) {
    var val
    e.preventDefault()
    val = $('#ev_search').val().trim()
    if (e.which === 13) {
      if (val.length !== 0) {
        return Meteor.call('search_ev', val.toString(), (function(_this) {
          return function(err, res) {
            if (err) {
              Bert.alert("" + err.reason, 'danger', 'growl-top-right')
            } else {
              Bert.alert("Searched " + val, 'success', 'growl-top-right')
            }
            return $('#ev_search').val('')
          }
        })(this))
      }
    }
  }
})




Template.franchisees.helpers({
  settings: function() {
    return {
      collection: 'franchisees',
      rowsPerPage: 10,
      showFilter: true,
      showRowCount: true,
      fields: [
        {
          key: 'ev.ID',
          label: 'JPID'
        }, {
          key: 'ev.FRANCHISEE',
          label: 'Name'
        }, {
          key: 'ev.FRANCH_EMAIL',
          label: 'Email'
        }, {
          key: 'ev.FRANCH_NAME',
          label: 'Short Name'
        }, {
          key: 'ev.TELE_CELL',
          label: 'Phone'
        }, {
          key: 'ev.MASTER_LICENSEE',
          label: 'Office'
        // }, {
        //   key: 'ev.ACCOUNT_STATUS',
        //   label: 'Status'
        }, {
          key: '',
          label: 'View',
          tmpl: Template.view_button
        }
      ]
    }
  }
})

Template.franchisees.events({
  'click .get_all_franchisees': function() {
    return Meteor.call('get_all_franchisees', function(err, res) {
      if (err) {
        return console.error(err)
      }
    })
  }
})

Template.franchisee_view.onCreated(function() {
  return this.autorun((function(_this) {
    return function() {
      return Meteor.subscribe('office_by_franchisee', FlowRouter.getParam('doc_id'))
    }
  })(this))
})