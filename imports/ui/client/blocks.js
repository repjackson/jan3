Template.toggle_boolean.events({
  'click #turn_on': function() {
    var obj;
    return Docs.update(FlowRouter.getParam('doc_id'), {
      $set: (
        obj = {},
        obj["" + this.key] = true,
        obj
      )
    });
  },
  'click #turn_off': function() {
    var obj;
    return Docs.update(FlowRouter.getParam('doc_id'), {
      $set: (
        obj = {},
        obj["" + this.key] = false,
        obj
      )
    });
  }
});

Template.toggle_boolean.helpers({
  is_on: function() {
    var page_doc;
    page_doc = Docs.findOne(FlowRouter.getParam('doc_id'));
    return page_doc["" + this.key];
  }
});

Template.add_button.events({
  'click #add': function() {
    var id;
    id = Docs.insert({
      type: this.type
    });
    return FlowRouter.go("/edit/" + id);
  }
});

Template.reference_type_single.onCreated(function() {
  return this.autorun((function(_this) {
    return function() {
      return Meteor.subscribe('docs', [], _this.data.type);
    };
  })(this));
});

Template.reference_type_multiple.onCreated(function() {
  return this.autorun((function(_this) {
    return function() {
      return Meteor.subscribe('docs', [], _this.data.type);
    };
  })(this));
});

Template.associated_users.helpers({
  associated_users: function() {
    if (this.assigned_to) {
      return Meteor.users.find({
        _id: {
          $in: this.assigned_to
        }
      });
    }
  }
});

Template.associated_incidents.onCreated(function() {
  return this.autorun((function(_this) {
    return function() {
      return Meteor.subscribe('docs', [], 'incident');
    };
  })(this));
});

Template.associated_incidents.helpers({
  incidents: function() {
    return Docs.find({
      type: 'incident'
    });
  }
});

Template.reference_type_single.helpers({
  settings: function() {
    return {
      position: 'bottom',
      limit: 10,
      rules: [
        {
          collection: Docs,
          field: "" + this.search_field,
          matchAll: true,
          filter: {
            type: "" + this.type
          },
          template: Template.office_result
        }
      ]
    };
  }
});

Template.reference_type_multiple.helpers({
  settings: function() {
    return {
      position: 'bottom',
      limit: 10,
      rules: [
        {
          collection: Docs,
          field: "" + this.search_field,
          matchAll: true,
          filter: {
            type: "" + this.type
          },
          template: Template.customer_result
        }
      ]
    };
  }
});

Template.reference_type_single.events({
  'autocompleteselect #search': function(event, template, doc) {
    var obj, searched_value;
    searched_value = doc["" + template.data.key];
    Docs.update(FlowRouter.getParam('doc_id'), {
      $set: (
        obj = {},
        obj["" + template.data.key] = "" + doc._id,
        obj
      )
    });
    return $('#search').val('');
  }
});

Template.reference_type_multiple.events({
  'autocompleteselect #search': function(event, template, doc) {
    var obj, searched_value;
    searched_value = doc["" + template.data.key];
    Docs.update(FlowRouter.getParam('doc_id'), {
      $addToSet: (
        obj = {},
        obj["" + template.data.key] = "" + doc._id,
        obj
      )
    });
    return $('#search').val('');
  }
});

Template.set_view_mode.helpers({
  view_mode_button_class: function() {
    if (Session.equals('view_mode', this.view)) {
      return 'active';
    } else {
      return '';
    }
  }
});

Template.set_view_mode.events({
  'click #set_view_mode': function() {
    return Session.set('view_mode', this.view);
  }
});

Template.set_session_button.events({
  'click .set_session_filter': function() {
    return Session.set("" + this.key, this.value);
  }
});

Template.set_session_button.helpers({
  filter_class: function() {
    if (Session.equals("" + this.key, "all")) {
      if (this.value === 'all') {
        return 'primary';
      } else {
        return 'basic';
      }
    } else if (Session.get("" + this.key)) {
      if (Session.equals("" + this.key, parseInt(this.value))) {
        return 'primary';
      } else {
        return 'basic';
      }
    }
  }
});

Template.set_session_item.events({
  'click .set_session_filter': function() {
    return Session.set("" + this.key, this.value);
  }
});

Template.delete_button.events({
  'click #delete': function() {
    var template;
    template = Template.currentData();
    return swal({
      title: 'Delete?',
      type: 'error',
      animation: false,
      showCancelButton: true,
      closeOnConfirm: true,
      cancelButtonText: 'Cancel',
      confirmButtonText: 'Delete',
      confirmButtonColor: '#da5347'
    }, (function(_this) {
      return function() {
        return console.log(template);
      };
    })(this));
  }
});

Template.edit_link.events({
  'blur #link': function() {
    var link;
    link = $('#link').val();
    return Docs.update(FlowRouter.getParam('doc_id'), {
      $set: {
        link: link
      }
    });
  }
});

Template.publish_button.events({
  'click #publish': function() {
    return Docs.update(FlowRouter.getParam('doc_id'), {
      $set: {
        published: true
      }
    });
  },
  'click #unpublish': function() {
    return Docs.update(FlowRouter.getParam('doc_id'), {
      $set: {
        published: false
      }
    });
  }
});

Template.call_method.events({
  'click .call_method': function() {
    return Meteor.call(this.name, Template.parentData(1)._id, function(err, res) {});
  }
});

Template.edit_author.onCreated(function() {
  return Meteor.subscribe('usernames');
});

Template.edit_author.events({
  "autocompleteselect input": function(event, template, doc) {
    if (confirm('Change author?')) {
      Docs.update(FlowRouter.getParam('doc_id'), {
        $set: {
          author_id: doc._id
        }
      });
      return $('#author_select').val("");
    }
  }
});

Template.edit_author.helpers({
  author_edit_settings: function() {
    return {
      position: 'bottom',
      limit: 10,
      rules: [
        {
          collection: Meteor.users,
          field: 'username',
          matchAll: true,
          template: Template.user_pill
        }
      ]
    };
  }
});

Template.small_doc_history.onCreated(function() {
  return this.autorun((function(_this) {
    return function() {
      return Meteor.subscribe('child_docs', _this.data._id, 1);
    };
  })(this));
});

Template.small_doc_history.helpers({
  doc_history_events: function() {
    var cursor;
    return cursor = Docs.find({
      parent_id: Template.currentData()._id,
      type: 'event'
    }, {
      sort: {
        timestamp: -1
      },
      limit: 1
    });
  }
});

Template.parent_link.onCreated(function() {
  return this.autorun((function(_this) {
    return function() {
      return Meteor.subscribe('parent_doc', _this.data._id);
    };
  })(this));
});

Template.parent_link.helpers({
  parent_doc: function() {
    return Docs.find({
      _id: Template.currentData().parent_id
    });
  }
});

Template.full_doc_history.onCreated(function() {
  return this.autorun((function(_this) {
    return function() {
      return Meteor.subscribe('child_docs', _this.data._id);
    };
  })(this));
});

Template.full_doc_history.helpers({
  doc_history_events: function(e, t) {
    return Docs.find({
      parent_id: Template.currentData()._id,
      type: 'event'
    }, {
      sort: {
        timestamp: -1
      }
    });
  }
});

Template.full_doc_history.events({
  'click #clear_events': function() {
    var doc_id;
    doc_id = FlowRouter.getParam('doc_id');
    if (confirm('Clear all events? Irriversible.')) {
      return Meteor.call('clear_incident_events', doc_id);
    }
  }
});

Template.incidents_by_type.onCreated(function() {
  return this.autorun((function(_this) {
    return function() {
      return Meteor.subscribe('docs', [], 'incident');
    };
  })(this));
});

Template.incidents_by_type.helpers({
  typed_incidents: function() {
    var incident_type_doc;
    incident_type_doc = Docs.findOne(FlowRouter.getParam('doc_id'));
    return Docs.find({
      type: 'incident',
      incident_type: incident_type_doc.slug
    }, {
      sort: {
        timestamp: -1
      }
    });
  }
});

Template.toggle_key.helpers({
  toggle_key_button_class: function() {
    var current_doc;
    current_doc = Docs.findOne(FlowRouter.getParam('doc_id'));
    if (this.value) {
      if (current_doc["" + this.key] === this.value) {
        return 'primary';
      }
    } else {
      return '';
    }
  }
});

Template.toggle_key.events({
  'click .toggle_key': function() {
    var doc_id, obj, obj1, obj2;
    doc_id = FlowRouter.getParam('doc_id');
    if (this.value) {
      return Docs.update({
        _id: doc_id
      }, {
        $set: (
          obj = {},
          obj["" + this.key] = "" + this.value,
          obj
        )
      }, (function(_this) {
        return function(err, res) {
          if (err) {
            return Bert.alert("Error changing " + _this.key + " to " + _this.value + ": " + error.reason, 'danger', 'growl-top-right');
          } else {
            Docs.insert({
              type: 'event',
              parent_id: doc_id,
              text: "changed " + _this.key + " to " + _this.value + "."
            });
            return Bert.alert("Changed " + _this.key + " to " + _this.value, 'success', 'growl-top-right');
          }
        };
      })(this));
    } else if (Template.parentData()["" + this.key] === true) {
      return Docs.update(doc_id, {
        $set: (
          obj1 = {},
          obj1["" + this.key] = false,
          obj1
        )
      });
    } else {
      return Docs.update(doc_id, {
        $set: (
          obj2 = {},
          obj2["" + this.key] = true,
          obj2
        )
      });
    }
  }
});

Template.toggle_boolean_checkbox.onRendered(function() {
  return Meteor.setTimeout(function() {
    return $('.checkbox').checkbox();
  }, 500);
});

Template.toggle_boolean_checkbox.events({
  'click .ui.toggle.checkbox': function(e, t) {
    var checkbox_value, doc_id, obj;
    doc_id = FlowRouter.getParam('doc_id');
    console.log(Template.parentData());
    checkbox_value = $("input[name=" + this.key + "]").is(":checked");
    console.log(this.key);
    console.log(checkbox_value);
    console.log(Docs.findOne(doc_id));
    return Docs.update(doc_id, {
      $set: (
        obj = {},
        obj["" + this.key] = checkbox_value,
        obj
      )
    });
  }
});

Template.toggle_user_published.events({
  'click #toggle_button': function(e, t) {
    var doc_id;
    doc_id = FlowRouter.getParam('doc_id');
    console.log(Template.parentData());
    console.log(this);
    return Meteor.users.update(this._id, {
      $set: {
        published: !this.published
      }
    });
  }
});

Template.radio_item.events({
  'click .ui.toggle.checkbox': function(e, t) {
    var doc_id, element, obj, radio_item_value;
    doc_id = FlowRouter.getParam('doc_id');
    element = t.find("input:radio[name=" + this.key + "]:checked");
    radio_item_value = $(element).val();
    return Docs.update(doc_id, {
      $set: (
        obj = {},
        obj["" + this.key] = radio_item_value,
        obj
      )
    });
  }
});

Template.multiple_user_select.events({
  'autocompleteselect #search': function(event, template, selected_user) {
    var key, page_doc;
    key = Template.parentData(0).key;
    page_doc = Docs.findOne(FlowRouter.getParam('doc_id'));
    Meteor.call('user_array_add', page_doc._id, key, selected_user, (function(_this) {
      return function(err, res) {
        if (err) {
          return Bert.alert("Error Assigning " + selected_user.username + ": " + err.reason, 'danger', 'growl-top-right');
        } else {
          return Bert.alert("Assigned " + selected_user.username + ".", 'success', 'growl-top-right');
        }
      };
    })(this));
    return $('#search').val('');
  },
  'click .pull_user': function() {
    var context;
    context = Template.currentData(0);
    console.log(context);
    return swal({
      title: "Remove " + this.username + "?",
      type: 'info',
      animation: false,
      showCancelButton: true,
      closeOnConfirm: true,
      cancelButtonText: 'Cancel',
      confirmButtonText: 'Unassign',
      confirmButtonColor: '#da5347'
    }, (function(_this) {
      return function() {
        var page_doc;
        page_doc = Docs.findOne(FlowRouter.getParam('doc_id'));
        return Meteor.call('user_array_pull', page_doc._id, context.key, _this, function(err, res) {
          if (err) {
            return Bert.alert("Error removing " + _this.username + ": " + err.reason, 'danger', 'growl-top-right');
          } else {
            return Bert.alert("Removed " + _this.username + ".", 'success', 'growl-top-right');
          }
        });
      };
    })(this));
  }
});

Template.single_user_select.events({
  'autocompleteselect #search': function(event, template, selected_user) {
    var key, obj, page_doc;
    key = Template.parentData(0).key;
    page_doc = Docs.findOne(FlowRouter.getParam('doc_id'));
    Docs.update(page_doc._id, {
      $set: (
        obj = {},
        obj["" + key] = selected_user.username,
        obj
      )
    });
    return $('#search').val('');
  },
  'click .pull_user': function() {
    var context;
    context = Template.currentData(0);
    return swal({
      title: "Remove " + this.username + "?",
      type: 'info',
      animation: false,
      showCancelButton: true,
      closeOnConfirm: true,
      cancelButtonText: 'Cancel',
      confirmButtonText: 'Unassign',
      confirmButtonColor: '#da5347'
    }, (function(_this) {
      return function() {
        var obj, page_doc;
        page_doc = Docs.findOne(FlowRouter.getParam('doc_id'));
        return Docs.update(page_doc._id, {
          $unset: (
            obj = {},
            obj["" + context.key] = 1,
            obj
          )
        });
      };
    })(this));
  }
});

Template.multiple_user_select.helpers({
  settings: function() {
    return {
      position: 'bottom',
      limit: 10,
      rules: [
        {
          collection: Meteor.users,
          field: 'username',
          matchAll: true,
          template: Template.user_result
        }
      ]
    };
  },
  user_array_users: function() {
    var context, list, parent_doc;
    context = Template.currentData(0);
    parent_doc = Docs.findOne(FlowRouter.getParam('doc_id'));
    return list = Meteor.users.find({
      _id: {
        $in: parent_doc["" + context.key]
      }
    }).fetch();
  }
});

Template.single_user_select.helpers({
  settings: function() {
    return {
      position: 'bottom',
      limit: 10,
      rules: [
        {
          collection: Meteor.users,
          field: 'username',
          matchAll: true,
          template: Template.user_result
        }
      ]
    };
  },
  selected_user: function() {
    var context, parent_doc;
    context = Template.currentData(0);
    parent_doc = Docs.findOne(FlowRouter.getParam('doc_id'));
    if (parent_doc["" + context.key]) {
      return Meteor.users.findOne({
        username: parent_doc["" + context.key]
      });
    } else {
      return false;
    }
  }
});

Template.view_sla_contact.helpers({
  selected_contact: function() {
    var context, parent_doc;
    context = Template.currentData(0);
    parent_doc = Docs.findOne(FlowRouter.getParam('doc_id'));
    if (parent_doc["" + context.key]) {
      return Meteor.users.findOne({
        username: parent_doc[parent_doc["" + context.key]]
      });
    } else {
      return false;
    }
  }
});

Template.many_doc_select.onCreated(function() {
  return this.autorun((function(_this) {
    return function() {
      return Meteor.subscribe('type', 'customer');
    };
  })(this));
});

Template.many_doc_select.events({
  'autocompleteselect #search': function(event, template, selected_doc) {
    var key, page_doc;
    key = Template.parentData(0).key;
    page_doc = Docs.findOne(FlowRouter.getParam('doc_id'));
    Meteor.call('doc_array_add', page_doc._id, key, selected_doc, (function(_this) {
      return function(err, res) {
        if (err) {
          return Bert.alert("Error Assigning " + selected_doc.text + ": " + err.reason, 'danger', 'growl-top-right');
        } else {
          return Bert.alert("Assigned " + selected_doc.text + ".", 'success', 'growl-top-right');
        }
      };
    })(this));
    return $('#search').val('');
  },
  'click .pull_doc': function() {
    var context;
    context = Template.currentData(0);
    console.log(context);
    return swal({
      title: "Remove " + this.title + " " + this.text + "?",
      type: 'info',
      animation: false,
      showCancelButton: true,
      closeOnConfirm: true,
      cancelButtonText: 'Cancel',
      confirmButtonText: 'Unassign',
      confirmButtonColor: '#da5347'
    }, (function(_this) {
      return function() {
        var page_doc;
        page_doc = Docs.findOne(FlowRouter.getParam('doc_id'));
        return Meteor.call('doc_array_pull', page_doc._id, context.key, _this, function(err, res) {
          if (err) {
            return Bert.alert("Error removing " + _this.title + " " + _this.text + ": " + err.reason, 'danger', 'growl-top-right');
          } else {
            return Bert.alert("Removed " + _this.title + " " + _this.text + ".", 'success', 'growl-top-right');
          }
        });
      };
    })(this));
  }
});

Template.single_doc_select.onCreated(function() {
  return this.autorun((function(_this) {
    return function() {
      return Meteor.subscribe('type', 'customer');
    };
  })(this));
});

Template.single_doc_select.events({
  'autocompleteselect #search': function(event, template, selected_doc) {
    var page_doc, save_key;
    save_key = Template.parentData(0).save_key;
    page_doc = Docs.findOne(FlowRouter.getParam('doc_id'));
    Meteor.call('link_doc', page_doc._id, save_key, selected_doc, (function(_this) {
      return function(err, res) {
        if (err) {
          return Bert.alert("Error Assigning " + selected_doc.cust_name + ": " + err.reason, 'danger', 'growl-top-right');
        } else {
          return Bert.alert("Assigned " + selected_doc.cust_name + ".", 'success', 'growl-top-right');
        }
      };
    })(this));
    return $('#search').val('');
  },
  'click .remove_doc': function() {
    var context;
    context = Template.currentData(0);
    console.log(context);
    return swal({
      title: "Remove " + this.cust_name + "?",
      type: 'info',
      animation: false,
      showCancelButton: true,
      closeOnConfirm: true,
      cancelButtonText: 'Cancel',
      confirmButtonText: 'Unassign',
      confirmButtonColor: '#da5347'
    }, (function(_this) {
      return function() {
        var page_doc;
        page_doc = Docs.findOne(FlowRouter.getParam('doc_id'));
        return Meteor.call('unlink_doc', page_doc._id, context.save_key, _this, function(err, res) {
          if (err) {
            return Bert.alert("Error removing " + _this.cust_name + ": " + err.reason, 'danger', 'growl-top-right');
          } else {
            return Bert.alert("Removed " + _this.cust_name + ".", 'success', 'growl-top-right');
          }
        });
      };
    })(this));
  }
});

Template.single_doc_select.helpers({
  settings: function() {
    return {
      position: 'bottom',
      limit: 10,
      rules: [
        {
          collection: Docs,
          field: "" + this.search_key,
          matchAll: true,
          filter: {
            type: "" + this.type
          },
          template: Template.doc_result
        }
      ]
    };
  },
  selected_doc: function() {
    var context, doc, parent_doc;
    context = Template.currentData(0);
    parent_doc = Docs.findOne(FlowRouter.getParam('doc_id'));
    doc = Docs.findOne({
      _id: parent_doc["" + context.save_key]
    });
    return doc;
  }
});

Template.single_doc_view.onCreated(function() {
  return this.autorun((function(_this) {
    return function() {
      return Meteor.subscribe('incident', FlowRouter.getParam('doc_id'));
    };
  })(this));
});

Template.single_doc_view.helpers({
  selected_doc: function() {
    var context, doc, parent_doc;
    context = Template.currentData(0);
    parent_doc = Docs.findOne(FlowRouter.getParam('doc_id'));
    doc = Docs.findOne({
      "ev.ID": parent_doc["" + context.key]
    });
    return doc;
  }
});

Template.view_multiple_user.onCreated(function() {
  return this.autorun((function(_this) {
    return function() {
      return Meteor.subscribe('users');
    };
  })(this));
});

Template.view_multiple_user.helpers({
  user_array_users: function() {
    var context, parent_doc;
    context = Template.parentData(1);
    parent_doc = Docs.findOne(context._id);
    return Meteor.users.find({
      _id: {
        $in: parent_doc["" + this.key]
      }
    });
  }
});

Template.doc_result.onCreated(function() {
  return this.autorun((function(_this) {
    return function() {
      return Meteor.subscribe('doc', _this.data._id);
    };
  })(this));
});

Template.doc_result.helpers({
  doc_context: function() {
    var context, found;
    context = Template.currentData(0);
    found = Docs.findOne(context._id);
    return found;
  }
});

Template.delete_button.onCreated(function() {
  return this.confirming = new ReactiveVar(false);
});

Template.delete_button.helpers({
  confirming: function() {
    return Template.instance().confirming.get();
  }
});

Template.delete_button.events({
  'click .delete': function(e, t) {
    return t.confirming.set(true);
  },
  'click .cancel': function(e, t) {
    return t.confirming.set(false);
  },
  'click .confirm': function(e, t) {
    Docs.remove(this._id);
    return FlowRouter.go("/view/" + this.parent_id);
  }
});

Template.session_delete_button.onCreated(function() {
  return this.confirming = new ReactiveVar(false);
});

Template.session_delete_button.helpers({
  confirming: function() {
    return Template.instance().confirming.get();
  }
});

Template.session_delete_button.events({
  'click .delete': function(e, t) {
    return t.confirming.set(true);
  },
  'click .cancel': function(e, t) {
    return t.confirming.set(false);
  },
  'click .confirm': function(e, t) {
    $(e.currentTarget).closest('.comment').transition('fade right');
    $(e.currentTarget).closest('.notification_segment').transition('fade right');
    return Meteor.setTimeout((function(_this) {
      return function() {
        return Docs.remove(_this._id);
      };
    })(this), 1000);
  }
});
Template.full_doc_history.onCreated(function() {
  return this.autorun((function(_this) {
    return function() {
      return Meteor.subscribe('child_docs', FlowRouter.getParam('doc_id'));
    };
  })(this));
});
