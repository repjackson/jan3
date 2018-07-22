import moment from 'moment'

var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

this.Docs = new Meteor.Collection('docs');

this.Settings = new Meteor.Collection('settings');

// Docs.before.insert( (userId, doc)=> {
//   var date, date_array, month, timestamp, weekday, weekdaynum, year;
//   timestamp = Date.now();
//   doc.timestamp = timestamp;
//   doc.updated = timestamp;
//   date = moment(timestamp).format('Do');
//   weekdaynum = moment(timestamp).isoWeekday();
//   weekday = moment().isoWeekday(weekdaynum).format('dddd');
//   month = moment(timestamp).format('MMMM');
//   year = moment(timestamp).format('YYYY');
//   date_array = [weekday, month, date, year];
//   if (_) {
//     date_array = _.map(date_array, function(el) {
//       return el.toString().toLowerCase();
//     });
//   }
//   doc.timestamp_tags = date_array;
//   doc.author_id = Meteor.userId();
//   doc.points = 0;
//   doc.read_by = [Meteor.userId()];
// });

Meteor.users.helpers({
  name: function() {
    var ref, ref1;
    if (((ref = this.profile) != null ? ref.first_name : void 0) && ((ref1 = this.profile) != null ? ref1.last_name : void 0)) {
      return this.profile.first_name + "  " + this.profile.last_name;
    } else {
      return "" + this.username;
    }
  },
  last_login: function() {
    var ref;
    return moment((ref = this.status) != null ? ref.lastLogin.date : void 0).fromNow();
  },
  users_customer: function() {
    var found;
    found = Docs.findOne({
      type: 'customer',
      "ev.ID": this.profile.customer_jpid
    });
    return found;
  },
  email: function() {
    if (this.emails) {
      return this.emails[0].address;
    }
  }
});

Docs.helpers({
  author: function() {
    return Meteor.users.findOne(this.author_id);
  },
  when: function() {
    return moment(this.timestamp).fromNow();
  },
  parent: function() {
    return Docs.findOne(this.parent_id);
  },
  customer: function() {
    return Docs.findOne(this.customer_id);
  },
  comment_count: function() {
    return Docs.find({
      type: 'comment',
      parent_id: this._id
    }).count();
  },
  children: function() {
    return Docs.find({
      parent_id: this._id
    });
  },
  franchisee_customers: function() {
    return Docs.find({
      type: 'customer',
      "ev.FRANCHISEE": this.ev.FRANCHISEE
    });
  },
  parent_franchisee: function() {
    return Docs.findOne({
      type: 'franchisee',
      "ev.FRANCHISEE": this.ev.FRANCHISEE
    });
  },
  incident_customer: function() {
    return Docs.findOne({
      type: 'customer',
      "ev.ID": this.customer_jpid
    });
  },
  parent_office: function() {
    var found;
    found = Docs.findOne({
      type: 'office',
      "ev.MASTER_LICENSEE": this.ev.MASTER_LICENSEE
    });
    if (found) {
      return found;
    }
  }
});

Meteor.methods({
  mark_read: function(doc) {
    var ref;
    if (doc.read_by && (ref = Meteor.userId(), indexOf.call(doc.read_by, ref) >= 0)) {
      return Docs.update(doc._id, {
        $pull: {
          read_by: Meteor.userId()
        },
        $inc: {
          read_count: -1
        }
      });
    } else {
      return Docs.update(doc._id, {
        $addToSet: {
          read_by: Meteor.userId()
        },
        $inc: {
          read_count: 1
        }
      });
    }
  },
  bookmark: function(doc) {
    var ref;
    if (doc.bookmarked_ids && (ref = Meteor.userId(), indexOf.call(doc.bookmarked_ids, ref) >= 0)) {
      return Docs.update(doc._id, {
        $pull: {
          bookmarked_ids: Meteor.userId()
        },
        $inc: {
          bookmarked_count: -1
        }
      });
    } else {
      return Docs.update(doc._id, {
        $addToSet: {
          bookmarked_ids: Meteor.userId()
        },
        $inc: {
          bookmarked_count: 1
        }
      });
    }
  }
});
