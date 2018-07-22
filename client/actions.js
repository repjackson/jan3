var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

Template.action.helpers({
  action_doc: function() {
    var action_doc;
    return action_doc = Docs.findOne(this.valueOf());
  }
});

Template.vote_button.helpers({
  vote_up_button_class: function() {
    var ref;
    if (!Meteor.userId()) {
      return 'disabled';
    } else if (this.upvoters && (ref = Meteor.userId(), indexOf.call(this.upvoters, ref) >= 0)) {
      return 'green';
    } else {
      return 'outline';
    }
  },
  vote_down_button_class: function() {
    var ref;
    if (!Meteor.userId()) {
      return 'disabled';
    } else if (this.downvoters && (ref = Meteor.userId(), indexOf.call(this.downvoters, ref) >= 0)) {
      return 'red';
    } else {
      return 'outline';
    }
  }
});

Template.vote_button.events({
  'click .vote_up': function(e, t) {
    if (Meteor.userId()) {
      return Meteor.call('vote_up', this._id);
    } else {
      return FlowRouter.go('/sign-in');
    }
  },
  'click .vote_down': function() {
    if (Meteor.userId()) {
      return Meteor.call('vote_down', this._id);
    } else {
      return FlowRouter.go('/sign-in');
    }
  }
});

Template.favorite_button.helpers({
  favorite_count: function() {
    return this.favorite_count;
  },
  favorite_item_class: function() {
    var ref;
    if (Meteor.userId()) {
      if (this.favoriters && (ref = Meteor.userId(), indexOf.call(this.favoriters, ref) >= 0)) {
        return 'red';
      } else {
        return 'outline';
      }
    } else {
      return 'grey disabled';
    }
  }
});

Template.favorite_button.events({
  'click .favorite_item': function(e, t) {
    if (Meteor.userId()) {
      Meteor.call('favorite', Template.parentData(0));
      return $(e.currentTarget).closest('.favorite_item').transition('pulse');
    } else {
      return FlowRouter.go('/sign-in');
    }
  }
});

Template.mark_complete_button.helpers({
  complete_button_class: function() {
    var ref;
    if (Meteor.user()) {
      if (this.completed_ids && (ref = Meteor.userId(), indexOf.call(this.completed_ids, ref) >= 0)) {
        return 'inverted';
      } else {
        return '';
      }
    } else {
      return 'grey disabled';
    }
  }
});

Template.mark_complete_button.events({
  'click .mark_complete': function(e, t) {
    if (Meteor.userId()) {
      Meteor.call('mark_complete', Template.parentData(0));
      return $(e.currentTarget).closest('.mark_complete').transition('pulse');
    } else {
      return FlowRouter.go('/sign-in');
    }
  }
});

Template.mark_doc_complete_button.helpers;

Template.mark_doc_complete_button.events({
  'click .mark_complete': function(e, t) {
    if (this.complete === true) {
      return Docs.update(this._id, {
        $set: {
          complete: false
        }
      });
    } else {
      return Docs.update(this._id, {
        $set: {
          complete: true
        }
      });
    }
  }
});

Template.mark_doc_approved_button.helpers;

Template.mark_doc_approved_button.events({
  'click .approve': function(e, t) {
    if (confirm('Approve Bug?')) {
      return Meteor.call('approve_bug', this._id, function() {});
    }
  },
  'click .unapprove': function() {
    return Docs.update(this._id, {
      $set: {
        approved: false
      }
    });
  }
});

Template.bookmark_button.helpers({
  bookmark_button_class: function() {
    var ref;
    if (Meteor.user()) {
      if (this.bookmarked_ids && (ref = Meteor.userId(), indexOf.call(this.bookmarked_ids, ref) >= 0)) {
        return 'blue';
      } else {
        return '';
      }
    } else {
      return 'basic disabled';
    }
  },
  bookmarked: function() {
    var ref, ref1;
    return ((ref = Meteor.user()) != null ? ref.bookmarked_ids : void 0) && (ref1 = this._id, indexOf.call(Meteor.user().bookmarked_ids, ref1) >= 0);
  }
});

Template.bookmark_button.events({
  'click .bookmark_button': function(e, t) {
    if (Meteor.userId()) {
      Meteor.call('bookmark', Template.parentData(0));
      return $(e.currentTarget).closest('.bookmark_button').transition('pulse');
    } else {
      return FlowRouter.go('/sign-in');
    }
  }
});

Template.reflect_button.events({
  'click #reflect': function() {
    var new_journal_id;
    new_journal_id = Docs.insert({
      type: 'journal_entry',
      content: '',
      parent_id: this._id
    });
    return FlowRouter.go("/edit/" + new_journal_id);
  }
});

Template.respond_button.events({
  'click #respond': function() {
    var response_id;
    response_id = Docs.insert({
      type: 'response',
      content: '',
      parent_id: this._id
    });
    return FlowRouter.go("/edit/" + response_id);
  }
});

Template.resonate_button.helpers({
  resonate_button_class: function() {
    var ref;
    if (Meteor.userId()) {
      if (this.favoriters && (ref = Meteor.userId(), indexOf.call(this.favoriters, ref) >= 0)) {
        return 'blue';
      } else {
        return '';
      }
    } else {
      return 'disabled basic';
    }
  }
});

Template.resonate_button.events({
  'click .resonate_button': function(e, t) {
    if (Meteor.userId()) {
      Meteor.call('favorite', Template.parentData(0));
      return $(e.currentTarget).closest('.resonate_button').transition('pulse');
    } else {
      return FlowRouter.go('/sign-in');
    }
  }
});

Template.mark_read_button.events({
  'click .mark_read': function(e, t) {
    return Meteor.call('mark_read', this);
  },
  'click .mark_unread': function(e, t) {
    return Meteor.call('mark_read', this);
  }
});

Template.mark_read_button.helpers({
  read: function() {
    var ref;
    return this.read_by && (ref = Meteor.userId(), indexOf.call(this.read_by, ref) >= 0);
  }
});

Template.mark_read_link.events({
  'click .mark_read': function(e, t) {
    return Meteor.call('mark_read', this);
  },
  'click .mark_unread': function(e, t) {
    return Meteor.call('mark_read', this);
  }
});

Template.mark_read_link.helpers({
  read: function() {
    var ref;
    return this.read_by && (ref = Meteor.userId(), indexOf.call(this.read_by, ref) >= 0);
  }
});

Template.read_by_list.onCreated(function() {
  return this.autorun((function(_this) {
    return function() {
      return Meteor.subscribe('read_by', Template.parentData()._id);
    };
  })(this));
});

Template.read_by_list.helpers({
  read_by: function() {
    if (this.read_by) {
      if (this.read_by.length > 0) {
        return Meteor.users.find({
          _id: {
            $in: this.read_by
          }
        });
      }
    } else {
      return false;
    }
  }
});

Template.notify_button.onRendered(function() {
  return this.autorun((function(_this) {
    return function() {
      if (_this.subscriptionsReady()) {
        return Meteor.setTimeout(function() {
          return $('.ui.accordion').accordion();
        }, 500);
      }
    };
  })(this));
});

Template.notify_button.events({
  "autocompleteselect input": function(event, template, selected_user) {
    var context_doc;
    context_doc = Template.parentData(4);
    Meteor.call('notify_user_about_document', context_doc._id, selected_user._id, (function(_this) {
      return function() {
        return Bert.alert((selected_user.name()) + " was notified.", 'info', 'growl-top-right');
      };
    })(this));
    Docs.update(context_doc._id, {
      $addToSet: {
        notified_ids: selected_user._id
      }
    });
    return $('#recipient_select').val("");
  },
  'click .remove_notified_user': function() {
    var context_doc;
    context_doc = Template.parentData(4);
    Meteor.call('remove_notification', context_doc._id, this._id, (function(_this) {
      return function() {
        return Bert.alert((_this.name()) + " was unnotified.", 'info', 'growl-top-right');
      };
    })(this));
    return Docs.update(context_doc._id, {
      $pull: {
        notified_ids: this._id
      }
    });
  }
});

Template.notify_button.helpers({
  recipient_select_settings: function() {
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
  },
  notified_users: function() {
    if (this.notified_ids) {
      if (this.notified_ids.length > 0) {
        return Meteor.users.find({
          _id: {
            $in: this.notified_ids
          }
        });
      }
    } else {
      return false;
    }
  }
});

// ---
// generated by coffee-script 1.9.2