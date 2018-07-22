Meteor.methods({
  calculate_child_count: function(doc_id) {
    var child_count;
    child_count = Docs.find({
      parent_id: doc_id
    }).count();
    return Docs.update(doc_id, {
      $set: {
        child_count: child_count
      }
    });
  },
  create_user: function(options) {
    var new_id;
    new_id = Accounts.createUser(options);
    return new_id;
  },
  update_username: function(username) {
    var userId;
    userId = Meteor.userId();
    if (!userId) {
      throw new Meteor.Error(401, "Unauthorized");
    }
    Accounts.setUsername(userId, username);
    return "Updated Username: " + username;
  },
  update_email: function(new_email) {
    var userId;
    userId = Meteor.userId();
    if (!userId) {
      throw new Meteor.Error(401, "Unauthorized");
    }
    Accounts.addEmail(userId, new_email);
    return "Updated Email to " + new_email;
  },
  tagify_timestamp: function(doc_id) {
    var ampm, date, date_array, doc, month, timestamp, weekday, weekdaynum, year;
    console.log('doc_id', doc_id);
    doc = Docs.findOne(doc_id);
    if (doc) {
      timestamp = doc.timestamp;
      date = moment(timestamp).format('Do');
      ampm = moment(timestamp).format('a');
      weekdaynum = moment(timestamp).isoWeekday();
      weekday = moment().isoWeekday(weekdaynum).format('dddd');
      month = moment(timestamp).format('MMMM');
      year = moment(timestamp).format('YYYY');
      date_array = [ampm, weekday, month, date, year];
      date_array = _.map(date_array, function(el) {
        return el.toString().toLowerCase();
      });
      Docs.update(doc_id, {
        $set: {
          timestamp_tags: date_array
        }
      });
      return date_array;
    }
  },
  verify_email: function(user_id) {
    return Accounts.sendVerificationEmail(user_id);
  },
  update_location: function(doc_id, result) {
    var component, doc, geocode, i, len, location_tags, lowered_location_tags, part, parts, tags_with_new, tags_without_address;
    location_tags = (function() {
      var i, len, ref, results;
      ref = result.address_components;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        component = ref[i];
        results.push(component.long_name);
      }
      return results;
    })();
    parts = result.address_components;
    geocode = {};
    for (i = 0, len = parts.length; i < len; i++) {
      part = parts[i];
      geocode["" + part.types[0]] = part.short_name;
    }
    geocode['formatted_address'] = result.formatted_address;
    console.log(result.lat);
    console.log(result.lng);
    lowered_location_tags = _.map(location_tags, function(tag) {
      return tag.toLowerCase();
    });
    doc = Docs.findOne(doc_id);
    tags_without_address = _.difference(doc.tags, doc.location_tags);
    tags_with_new = _.union(tags_without_address, lowered_location_tags);
    return Docs.update(doc_id, {
      $set: {
        tags: tags_with_new,
        location_ob: result,
        location_tags: lowered_location_tags,
        geocode: geocode,
        location_lat: result.lat,
        location_lng: result.lng
      }
    });
  },
  create_message: function(recipient_id, text, parent_id) {
    var convo_id, found_conversation, new_conversation_id, new_message_id;
    found_conversation = Docs.findOne({
      type: 'conversation',
      participant_ids: {
        $all: [Meteor.userId(), recipient_id]
      }
    });
    if (found_conversation) {
      convo_id = found_conversation._id;
    } else {
      new_conversation_id = Docs.insert({
        type: 'conversation',
        participant_ids: [Meteor.userId(), recipient_id]
      });
      convo_id = new_conversation_id;
    }
    new_message_id = new_message_id = Docs.insert({
      type: 'message',
      group_id: convo_id,
      parent_id: parent_id,
      body: text
    });
    return new_message_id;
  },
  notify_user_about_document: function(doc_id, recipient_id) {
    var doc, doc_link, notification, parent, recipient;
    doc = Docs.findOne(doc_id);
    parent = Docs.findOne(doc.parent_id);
    recipient = Meteor.users.findOne(recipient_id);
    doc_link = "/view/" + doc._id;
    notification = Docs.findOne({
      type: 'notification',
      object_id: doc_id,
      recipient_id: recipient_id
    });
    if (notification) {
      throw new Meteor.Error(500, 'User already notified.');
    } else {
      return Docs.insert({
        type: 'notification',
        object_id: doc_id,
        recipient_id: recipient_id,
        content: "<p>" + (Meteor.user().name()) + " has notified you about <a href=" + doc_link + ">" + parent.title + " entry</a>.</p>"
      });
    }
  },
  remove_notification: function(doc_id, recipient_id) {
    var doc, notification, recipient;
    doc = Docs.findOne(doc_id);
    recipient = Meteor.users.findOne(recipient_id);
    notification = Docs.findOne({
      type: 'notification',
      object_id: doc_id,
      recipient_id: recipient_id
    });
    if (notification) {
      Docs.remove(notification._id);
    } else {
      console.log('trying to remove unknown notification');
    }
  },
  assign_user: function(doc_id, user) {
    var doc;
    doc = Docs.findOne(doc_id);
    Docs.update(doc_id, {
      $addToSet: {
        assigned_to: user._id
      }
    });
    return Docs.insert({
      type: 'event',
      parent_id: doc_id,
      event_type: 'assignment',
      text: user.username + " was assigned to " + doc.type
    });
  },
  user_array_add: function(doc_id, key, user) {
    var doc, obj;
    doc = Docs.findOne(doc_id);
    Docs.update(doc_id, {
      $addToSet: (
        obj = {},
        obj["" + key] = user._id,
        obj
      )
    });
    return Docs.insert({
      type: 'event',
      parent_id: doc_id,
      event_key: key,
      text: user.username + " was added to " + key + " on " + doc.type
    });
  },
  user_array_pull: function(doc_id, key, user) {
    var doc, obj;
    doc = Docs.findOne(doc_id);
    Docs.update(doc_id, {
      $pull: (
        obj = {},
        obj["" + key] = user._id,
        obj
      )
    });
    return Docs.insert({
      type: 'event',
      parent_id: doc_id,
      event_key: key,
      text: user.username + " was removed from " + key + "."
    });
  },
  link_doc: function(doc_id, key, doc) {
    var obj, obj1;
    if (key === 'customer_id') {
      console.log(doc.cust_name);
      console.log(doc.jpid);
      Docs.update(doc_id, {
        $set: (
          obj = {},
          obj["" + key] = doc._id,
          obj.customer_name = doc.cust_name,
          obj.customer_jpid = doc.jpid,
          obj
        )
      });
    } else {
      Docs.update(doc_id, {
        $set: (
          obj1 = {},
          obj1["" + key] = doc._id,
          obj1
        )
      });
    }
    return Docs.insert({
      type: 'event',
      parent_id: doc_id,
      event_key: key,
      text: doc.text + " was added to " + key + " on " + doc.type
    });
  },
  unlink_doc: function(doc_id, key, doc) {
    var obj;
    doc = Docs.findOne(doc_id);
    Docs.update(doc_id, {
      $unset: (
        obj = {},
        obj["" + key] = 1,
        obj
      )
    });
    return Docs.insert({
      type: 'event',
      parent_id: doc_id,
      event_key: key,
      text: doc.text + " was removed from " + key + "."
    });
  },
  unassign_user: function(doc_id, user) {
    var doc;
    doc = Docs.findOne(doc_id);
    Docs.update(doc_id, {
      $pull: {
        assigned_to: user._id
      }
    });
    return Docs.insert({
      type: 'event',
      parent_id: doc_id,
      event_type: 'assignment',
      text: user.username + " was unassigned from " + doc.type
    });
  },
  create_event: function(parent_id, event_type, action) {
    console.log("creating event with parent_id " + parent_id + " of type: " + event_type + " and action " + action);
    return Docs.insert({
      type: 'event',
      parent_id: parent_id,
      event_type: event_type,
      action: action
    });
  },
  set_incident_level: function(target_id, event_type, level) {
    var current_user, doc;
    doc = Docs.findOne(target_id);
    current_user = Meteor.users.findOne(this.userId);
    if (doc) {
      Docs.update({
        target_id: target_id
      }, {
        $set: {
          level: level
        }
      });
      return Docs.insert({
        type: 'event',
        parent_id: target_id,
        event_type: 'change_level',
        text: current_user.username + " changed level to " + level
      });
    }
  },
  create_alert: function(type, parent_id, comment_id) {
    var doc, new_alert_id;
    doc = Docs.findOne(comment_id);
    if (type === 'comment') {
      new_alert_id = Docs.insert({
        type: 'event',
        event_type: 'comment',
        parent_id: parent_id,
        comment_id: comment_id,
        text: (doc.author().username) + " commented " + doc.text + "."
      });
      return new_alert_id;
    } else {
      throw new Meteor.Error('unknown_type', 'unknown alert type');
    }
  },
  create_conversation: function(tags) {
    if (tags == null) {
      tags = [];
    }
    return Docs.insert({
      tags: tags,
      type: 'conversation',
      subscribers: [Meteor.userId()],
      participant_ids: [Meteor.userId()]
    });
  },
  close_conversation: function(conversation_id) {
    Docs.remove(conversation_id);
    return Docs.remove({
      type: 'message',
      group_id: conversation_id
    });
  },
  join_conversation: function(conversation_id) {
    return Docs.update(conversation_id, {
      $addToSet: {
        participant_ids: Meteor.userId()
      }
    });
  },
  leave_conversation: function(conversation_id) {
    return Docs.update(conversation_id, {
      $pull: {
        participant_ids: Meteor.userId()
      }
    });
  },
  add_message: function(body, group_id) {
    var conversation_doc, i, j, len, len1, message_author, message_doc, message_link, new_message_id, offline_id, offline_ids, offline_user, participant_id, ref, user;
    new_message_id = Docs.insert({
      body: body,
      type: 'message',
      group_id: group_id,
      tags: ['conversation', 'message']
    });
    conversation_doc = Docs.findOne({
      _id: group_id
    });
    message_doc = Docs.findOne(new_message_id);
    message_author = Meteor.users.findOne(message_doc.author_id);
    message_link = "https://www.jan.meteorapp.com/view/" + conversation_doc._id;
    this.unblock();
    offline_ids = [];
    ref = conversation_doc.participant_ids;
    for (i = 0, len = ref.length; i < len; i++) {
      participant_id = ref[i];
      user = Meteor.users.findOne(participant_id);
      console.log(participant_id);
      if (user.status.online === true) {
        console.log('user online:', user.profile.first_name);
      } else {
        offline_ids.push(user._id);
        console.log('user offline:', user.profile.first_name);
      }
    }
    for (j = 0, len1 = offline_ids.length; j < len1; j++) {
      offline_id = offline_ids[j];
      console.log('offline id', offline_id);
      offline_user = Meteor.users.findOne(offline_id);
      Email.send({
        to: " " + offline_user.profile.first_name + " " + offline_user.profile.last_name + " <" + offline_user.emails[0].address + ">",
        from: "Jan-Pro Customer Portal Admin <no-reply@jan-pro.com>",
        subject: "New Message from " + message_author.profile.first_name + " " + message_author.profile.last_name,
        html: "<h4>" + message_author.profile.first_name + " just sent the following message while you were offline: </h4> " + text + " <br><br> Click <a href=" + message_link + "> here to view.</a><br><br> You can unsubscribe from this conversation in the Actions panel."
      });
    }
    return new_message_id;
  },
  update_escalation_statuses: function() {
    var i, incident, len, open_incidents, ref, results;
    open_incidents = Docs.find({
      type: 'incident',
      open: true
    }, {
      limit: 1
    });
    console.log(open_incidents.count());
    ref = open_incidents.fetch();
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      incident = ref[i];
      results.push(Meteor.call('single_escalation_check', incident._id));
    }
    return results;
  },
  single_escalation_check: function(incident_id) {
    var current_level, escalation_calculation, hours_value, incident, incident_office, last_updated, minutes_elapsed, next_level, now, seconds_elapsed, updated_now_difference;
    incident = Docs.findOne(incident_id);
    if (incident.level === 4) {
      return Meteor.call('create_event', incident_id, 'max_level_notice', "Incident is at max level 4, not escalating.");
    } else {
      incident_office = Docs.findOne({
        "ev.MASTER_LICENSEE": incident.incident_office_name,
        type: 'office'
      });
      current_level = incident.level;
      next_level = current_level + 1;
      last_updated = incident.updated;
      hours_value = incident_office["escalation_" + next_level + "_hours"];
      now = Date.now();
      console.log('hours value', hours_value);
      console.log('last_updated value', last_updated);
      updated_now_difference = now - last_updated;
      console.log('difference between last updated and now', updated_now_difference);
      seconds_elapsed = Math.floor(updated_now_difference / 1000);
      console.log('seconds elapsed =', seconds_elapsed);
      minutes_elapsed = Math.floor(seconds_elapsed / 60);
      console.log('minutes elapsed =', minutes_elapsed);
      escalation_calculation = minutes_elapsed - hours_value;
      console.log('escalation_calculation', escalation_calculation);
      if (minutes_elapsed < hours_value) {
        return Meteor.call('create_event', incident_id, 'not-escalate', minutes_elapsed + " minutes have elapsed, less than " + hours_value + " in the escalations level " + next_level + " rules, not escalating.");
      } else {
        Meteor.call('create_event', incident_id, 'escalate', minutes_elapsed + " minutes have elapsed, more than " + hours_value + " in the escalations level " + next_level + " rules, escalating.");
        return Meteor.call('escalate_incident', incident._id, function() {});
      }
    }
  },
  escalate_incident: function(doc_id) {
    var current_level, incident, next_level;
    incident = Docs.findOne(doc_id);
    current_level = incident.level;
    if (current_level > 3) {
      console.log("current level is 4, cant escalate beyond");
      return Docs.update(doc_id, {
        $set: {
          level: current_level - 1
        }
      });
    } else {
      next_level = current_level + 1;
      console.log('escalating doc id', doc_id);
      Docs.update(doc_id, {
        $set: {
          level: next_level,
          updated: Date.now()
        }
      });
      Meteor.call('create_event', doc_id, 'escalate', "Incident was automatically escalated from " + current_level + " to " + next_level + ".");
      return Meteor.call('email_about_escalation', doc_id);
    }
  },
  clear_incident_events: function(incident_id) {
    var cursor, event_doc, i, len, ref, results;
    cursor = Docs.find({
      parent_id: incident_id,
      type: 'event'
    });
    ref = cursor.fetch();
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      event_doc = ref[i];
      results.push(Docs.remove(event_doc._id));
    }
    return results;
  },
  check_username: function(username) {
    var found_user;
    found_user = Accounts.findUserByUsername(username);
    console.log(found_user);
    return found_user;
  },
  check_email: function(email) {
    var found_user;
    found_user = Accounts.findUserByEmail(email);
    console.log(found_user);
    return found_user;
  }
});

// ---
// generated by coffee-script 1.9.2