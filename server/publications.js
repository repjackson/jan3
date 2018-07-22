Meteor.publish('type', function(type) {
  return Docs.find({type:type}, {limit: 100})
})

Meteor.publish('users_feed', function(username) {
  var user
  user = Meteor.users.findOne({
    username: username
  })
  return Docs.find({
    type: 'event',
    author_id: user._id
  }, {
    limit: 20
  })
})

ReactiveTable.publish('users', Meteor.users, '', {disablePageCountReactivity: true})

ReactiveTable.publish('customers', Docs, {type:'customer', "ev.ACCOUNT_STATUS":'ACTIVE'}, {disablePageCountReactivity: true})

ReactiveTable.publish('events', Docs, {type: 'event'}, {disablePageCountReactivity: false})

ReactiveTable.publish('franchisees', Docs, {type: 'franchisee'}, {disablePageCountReactivity: true})

ReactiveTable.publish('incidents', Docs, {type:'incident'}, {disablePageCountReactivity: true})

ReactiveTable.publish('offices', Docs, {type: 'office'}, {disablePageCountReactivity: true})

ReactiveTable.publish('special_services', Docs, {type:'special_service'}, {disablePageCountReactivity: true})

ReactiveTable.publish('jpids', Docs, {type: 'jpid'}, {disablePageCountReactivity: true})

ReactiveTable.publish('search_history_docs', Docs, {type: 'search_history_doc'}, {disablePageCountReactivity: true})

ReactiveTable.publish('office_employees', function(input) {return console.log('input', input)})

Meteor.publish('child_docs', function(doc_id, limit) {
  if (limit) {
    return Docs.find({
      parent_id: doc_id
    }, {
      limit: limit,
      sort: {
        timestamp: -1
      }
    })
  } else {
    return Docs.find({
      parent_id: doc_id
    })
  }
})

Meteor.publish('parent_doc', function(child_id) {
  var child
  child = Docs.findOne(child_id)
  return Docs.find({
    _id: child.parent_id
  })
})

publishComposite('office', function(office_id) {
  return {
    find: function() {
      return Docs.find(office_id)
    }
  }
})

Meteor.publish('has_key', function(key) {
  var obj
  return Docs.find((
    obj = {},
    obj["ev." + key] = {
      $exists: true
    },
    obj
  ))
})

Meteor.publish('has_key_value', function(key, value) {
  var obj
  return Docs.find((
    obj = {},
    obj["ev." + key] = value,
    obj
  ))
})

Meteor.publish('office_customers', function(office_doc_id) {
  var office_doc
  office_doc = Docs.findOne(office_doc_id)
  return Docs.find({
    "ev.MASTER_LICENSEE": office_doc.ev.MASTER_LICENSEE,
    type: "customer"
  })
})

Meteor.publish('office_incidents', function(office_doc_id) {
  var office_doc
  office_doc = Docs.findOne(office_doc_id)
  return Docs.find({
    incident_office_name: office_doc.ev.MASTER_LICENSEE,
    type: "incident"
  })
})

Meteor.publish('office_franchisees', function(office_doc_id) {
  var office_doc
  office_doc = Docs.findOne(office_doc_id)
  return Docs.find({
    type: "franchisee",
    "ev.MASTER_LICENSEE": office_doc.ev.MASTER_LICENSEE
  })
})

Meteor.publish('office_employees', function(office_doc_id) {
  var office_doc
  office_doc = Docs.findOne(office_doc_id)
  return Meteor.users.find({
    "profile.office_name": office_doc.ev.MASTER_LICENSEE
  })
})

Meteor.publish('my_conversations', function() {
  return Docs.find({
    type: 'conversation',
    participant_ids: {
      $in: [Meteor.userId()]
    }
  })
})

Meteor.publish('my_customer_incidents', function() {
  var user
  user = Meteor.user()
  if (user.profile && user.profile.customer_jpid) {
    return Docs.find({
      customer_jpid: user.profile.customer_jpid,
      type: "incident"
    })
  }
})

publishComposite('docs', function(selected_tags, type) {
  return {
    find: function() {
      var match, self
      self = this
      match = {}
      if (type) {
        match.type = type
      }
      return Docs.find(match, {
        limit: 20
      })
    },
    children: [
      {
        find: function(doc) {
          return Meteor.users.find({
            _id: doc.author_id
          })
        }
      }, {
        find: function(doc) {
          return Docs.find({
            _id: doc.parent_id
          })
        }
      }
    ]
  }
})

publishComposite('incidents', function(level) {
  return {
    find: function() {
      var match, self
      self = this
      match = {}
      match.type = 'incident'
      return Docs.find(match)
    },
    children: [
      {
        find: function(doc) {
          return Meteor.users.find({
            _id: doc.author_id
          })
        }
      }, {
        find: function(doc) {
          return Docs.find({
            _id: doc.parent_id
          })
        }
      }
    ]
  }
})

Meteor.publish('my_profile', function() {
  return Meteor.users.find(this.userId, {
    fields: {
      tags: 1,
      profile: 1,
      username: 1,
      published: 1,
      image_id: 1
    }
  })
})

Meteor.publish('user', function(username) {
  return Meteor.users.find({
    username: username
  }, {
    fields: {
      profile: 1,
      username: 1,
      ev: 1,
      published: 1
    }
  })
})

Meteor.publish('user_profile', function(user_id) {
  return Meteor.users.find(user_id, {
    fields: {
      profile: 1,
      username: 1,
      ev: 1,
      published: 1
    }
  })
})

Meteor.publish('office_by_franchisee', function(franch_id) {
  var found, franch_doc
  franch_doc = Docs.findOne(franch_id)
  if (franch_doc.ev) {
    found = Docs.find({
      type: 'office',
      "ev.MASTER_OFFICE_NAME": franch_doc.ev.MASTER_LICENSEE
    })
    return found
  }
})

Meteor.publish('my_customer_account', function() {
  var user
  user = Meteor.user()
  if (user && user.profile && user.profile.customer_jpid) {
    return Docs.find({
      "ev.ID": user.profile.customer_jpid,
      type: 'customer'
    })
  }
})

Meteor.publish('my_franchisee', function() {
  var customer_doc, user
  user = Meteor.user()
  if (user && user.profile && user.profile.customer_jpid) {
    customer_doc = Docs.findOne({
      "ev.ID": user.profile.customer_jpid,
      type: 'customer'
    })
    return Docs.find({
      "ev.FRANCHISEE": customer_doc.ev.FRANCHISEE,
      type: 'franchisee'
    })
  }
})

Meteor.publish('my_office', function() {
  var customer_doc, user
  user = Meteor.user()
  if (user && user.profile && user.profile.customer_jpid) {
    customer_doc = Docs.findOne({
      "ev.ID": user.profile.customer_jpid,
      type: 'customer'
    })
    return Docs.find({
      "ev.MASTER_LICENSEE": customer_doc.ev.MASTER_LICENSEE,
      type: 'office'
    })
  }
})

Meteor.publish('my_special_services', function() {
  var customer_doc, user
  user = Meteor.user()
  if (user.profile.customer_jpid) {
    customer_doc = Docs.findOne({
      "ev.ID": user.profile.customer_jpid,
      type: 'customer'
    })
    return Docs.find({
      type: 'special_service',
      "ev.CUSTOMER": customer_doc.ev.CUST_NAME
    }, {
      limit: 20
    })
  }
})

Meteor.publish('my_office_contacts', function() {
  var customer_doc, user
  user = Meteor.user()
  if (user.profile.customer_jpid) {
    customer_doc = Docs.findOne({
      "ev.ID": user.profile.customer_jpid,
      type: 'customer'
    })
    return Meteor.users.find({
      "profile.office_name": customer_doc.ev.MASTER_LICENSEE
    }, {
      limit: 100
    })
  }
})

publishComposite('doc', function(id) {
  return {
    find: function() {
      return Docs.find(id)
    },
    children: [
      {
        find: function(doc) {
          return Meteor.users.find({
            _id: doc.author_id
          })
        }
      }, {
        find: function(doc) {
          return Docs.find({
            _id: doc.referenced_office_id
          })
        }
      }, {
        find: function(doc) {
          return Docs.find({
            _id: doc.referenced_customer_id
          })
        }
      }, {
        find: function(doc) {
          return Docs.find({
            _id: doc.parent_id
          })
        }
      }
    ]
  }
})

publishComposite('incident', function(id) {
  return {
    find: function() {
      return Docs.find(id)
    },
    children: [
      {
        find: function(incident) {
          return Meteor.users.find({
            _id: incident.author_id
          })
        }
      }, {
        find: function(incident) {
          return Docs.find({
            type: 'customer',
            "ev.ID": incident.customer_jpid
          })
        }
      }
    ]
  }
})

publishComposite('me', function() {
  return {
    find: function() {
      return Meteor.users.find(this.userId)
    },
    children: [
      {
        find: function(user) {
          return Docs.find({
            "ev.ID": user.profile.customer_jpid,
            type: 'customer'
          })
        }
      }
    ]
  }
})

Meteor.publish('comments', function(doc_id) {
  return Docs.find({
    parent_id: doc_id,
    type: 'comment'
  })
})

Meteor.publish('people_list', function(conversation_id) {
  var conversation
  conversation = Docs.findOne(conversation_id)
  return Meteor.users.find({
    _id: {
      $in: conversation.participant_ids
    }
  })
})

publishComposite('participant_ids', function(selected_theme_tags, selected_participant_ids) {
  return {
    find: function() {
      var cloud, match, self
      self = this
      match = {}
      match.type = 'conversation'
      if (selected_theme_tags.length > 0) {
        match.tags = {
          $all: selected_theme_tags
        }
      }
      if (selected_participant_ids.length > 0) {
        match.participant_ids = {
          $in: selected_participant_ids
        }
      }
      match.published = true
      cloud = Docs.aggregate([
        {
          $match: match
        }, {
          $project: {
            participant_ids: 1
          }
        }, {
          $unwind: "$participant_ids"
        }, {
          $group: {
            _id: '$participant_ids',
            count: {
              $sum: 1
            }
          }
        }, {
          $match: {
            _id: {
              $nin: selected_participant_ids
            }
          }
        }, {
          $sort: {
            count: -1,
            _id: 1
          }
        }, {
          $limit: 20
        }, {
          $project: {
            _id: 0,
            text: '$_id',
            count: 1
          }
        }
      ])
      cloud.forEach(function(participant_ids) {
        return self.added('participant_ids', Random.id(), {
          text: participant_ids.text,
          count: participant_ids.count
        })
      })
      return self.ready()
    }
  }
})

Meteor.publish('conversations', function(selected_theme_tags, selected_participant_ids, view_published) {
  var cursor, match, self
  self = this
  match = {}
  if (selected_theme_tags.length > 0) {
    match.tags = {
      $all: selected_theme_tags
    }
  }
  if (view_published === true) {
    match.published = 1
    if (selected_participant_ids.length > 0) {
      match.participant_ids = {
        $in: selected_participant_ids
      }
    }
  } else if (view_published = false) {
    match.published = -1
    selected_participant_ids.push(Meteor.userId())
    match.participant_ids = {
      $in: selected_participant_ids
    }
  }
  match.type = 'conversation'
  cursor = Docs.find(match)
  return cursor
})

publishComposite('group_docs', function(group_id) {
  return {
    find: function() {
      return Docs.find({
        group_id: group_id
      })
    },
    children: [
      {
        find: function(doc) {
          return Docs.find({
            _id: doc.parent_id
          })
        },
        children: [
          {
            find: function(doc) {
              return Docs.find({
                _id: doc.parent_id
              })
            },
            children: [
              {
                find: function(doc) {
                  return Docs.find({
                    _id: doc.parent_id
                  })
                }
              }
            ]
          }, {
            find: function(doc) {
              return Meteor.users.find({
                _id: doc.author_id
              })
            }
          }
        ]
      }, {
        find: function(doc) {
          return Meteor.users.find({
            _id: doc.author_id
          })
        }
      }
    ]
  }
})

Meteor.publish('userStatus', function() {
  return Meteor.users.find({
    'status.online': true
  }, {
    fields: {
      points: 1,
      tags: 1
    }
  })
})

Meteor.publish('user_status_notification', function() {
  return Meteor.users.find({
    'status.online': true
  }).observe({
    added: function(id) {
      return console.log(id + " just logged in")
    },
    removed: function(id) {
      return console.log(id + " just logged out")
    }
  })
})