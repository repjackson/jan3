var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

Template.edit_image_field.events({
  "change input[type='file']": function(e) {
    var doc_id, files;
    doc_id = FlowRouter.getParam('doc_id');
    files = e.currentTarget.files;
    return Cloudinary.upload(files[0], function(err, res) {
      if (err) {
        console.error('Error uploading', err);
        Bert.alert("Error uploading " + this.label + ": " + err, 'danger', 'growl-top-right');
      } else {
        Docs.update(doc_id, {
          $set: {
            image_id: res.public_id
          }
        }, (function(_this) {
          return function(err, res) {
            if (err) {
              return Bert.alert("Error Updating Image: " + err.reason, 'danger', 'growl-top-right');
            } else {
              return Bert.alert("Updated Image", 'success', 'growl-top-right');
            }
          };
        })(this));
      }
    });
  },
  'keydown #input_image_id': function(e, t) {
    var doc_id, image_id;
    if (e.which === 13) {
      doc_id = FlowRouter.getParam('doc_id');
      image_id = $('#input_image_id').val().toLowerCase().trim();
      if (image_id.length > 0) {
        Docs.update(doc_id, {
          $set: {
            image_id: image_id
          }
        });
        return $('#input_image_id').val('');
      }
    }
  },
  'click #remove_photo': function() {
    return swal({
      title: 'Remove Photo?',
      type: 'warning',
      animation: false,
      showCancelButton: true,
      closeOnConfirm: true,
      cancelButtonText: 'No',
      confirmButtonText: 'Remove',
      confirmButtonColor: '#da5347'
    }, (function(_this) {
      return function() {
        return Meteor.call("c.delete_by_public_id", _this.image_id, function(err, res) {
          if (!err) {
            return Docs.update(FlowRouter.getParam('doc_id'), {
              $unset: {
                image_id: 1
              }
            });
          } else {
            throw new Meteor.Error("it failed");
          }
        });
      };
    })(this));
  }
});

Template.edit_number_field.events({
  'change #number_field': function(e, t) {
    var number_value, obj;
    number_value = parseInt(e.currentTarget.value);
    return Docs.update(FlowRouter.getParam('doc_id'), {
      $set: (
        obj = {},
        obj["" + this.key] = number_value,
        obj
      )
    }, (function(_this) {
      return function(err, res) {
        if (err) {
          return Bert.alert("Error Updating " + _this.label + ": " + err.reason, 'danger', 'growl-top-right');
        } else {
          return Bert.alert("Updated " + _this.label, 'success', 'growl-top-right');
        }
      };
    })(this));
  }
});

Template.edit_textarea.events({
  'blur #textarea': function(e, t) {
    var doc_id, obj, textarea_value;
    doc_id = FlowRouter.getParam('doc_id');
    textarea_value = $('#textarea').val();
    return Docs.update(doc_id, {
      $set: (
        obj = {},
        obj["" + this.key] = textarea_value,
        obj
      )
    }, (function(_this) {
      return function(err, res) {
        if (err) {
          return Bert.alert("Error Updating " + _this.label + ": " + err.reason, 'danger', 'growl-top-right');
        } else {
          return Bert.alert("Updated " + _this.label, 'success', 'growl-top-right');
        }
      };
    })(this));
  }
});

Template.edit_textarea.helpers({
  'key_value': function() {
    var current_doc, doc_field;
    doc_field = Template.parentData(0);
    current_doc = Docs.findOne(FlowRouter.getParam('doc_id'));
    if (current_doc) {
      if (doc_field.key) {
        return current_doc["" + doc_field.key];
      }
    }
  }
});

Template.edit_timerange_field.onRendered(function() {
  return Meteor.setTimeout(function() {
    $('#time_start').calendar({
      type: 'datetime',
      today: true,
      firstDayOfWeek: 0,
      constantHeight: true,
      endCalendar: $('#time_end')
    });
    return $('#time_end').calendar({
      type: 'datetime',
      today: true,
      firstDayOfWeek: 0,
      constantHeight: true,
      startCalendar: $('#time_start')
    });
  }, 500);
});

Template.edit_timerange_field.events({
  'blur #time_start': function(e, t) {
    var value;
    value = $('#time_start').calendar('get date');
    return Docs.update(FlowRouter.getParam('doc_id'), {
      $set: {
        time_start: value
      }
    }, (function(_this) {
      return function(err, res) {
        if (err) {
          return Bert.alert("Error Updating Start Time: " + err.reason, 'danger', 'growl-top-right');
        } else {
          return Bert.alert("Updated Start Time", 'success', 'growl-top-right');
        }
      };
    })(this));
  },
  'blur #time_end': function(e, t) {
    var value;
    value = $('#time_end').calendar('get date');
    return Docs.update(FlowRouter.getParam('doc_id'), {
      $set: {
        time_end: value
      }
    }, (function(_this) {
      return function(err, res) {
        if (err) {
          return Bert.alert("Error Updating End Time: " + err.reason, 'danger', 'growl-top-right');
        } else {
          return Bert.alert("Updated End Time", 'success', 'growl-top-right');
        }
      };
    })(this));
  }
});

Template.edit_datetime_field.onRendered(function() {
  return Meteor.setTimeout(function() {
    return $('#semcal').calendar({
      type: 'datetime',
      today: true,
      inline: true,
      firstDayOfWeek: 0,
      constantHeight: true
    });
  }, 500);
});

Template.edit_datetime_field.events({
  'blur #datetime_field': function(e, t) {
    var datetime_value, obj, value;
    datetime_value = e.currentTarget.value;
    value = $('#datetime_field').calendar('get date');
    return Docs.update(FlowRouter.getParam('doc_id'), {
      $set: (
        obj = {},
        obj["" + this.key] = datetime_value,
        obj
      )
    }, (function(_this) {
      return function(err, res) {
        if (err) {
          return Bert.alert("Error Updating " + _this.label + ": " + err.reason, 'danger', 'growl-top-right');
        } else {
          return Bert.alert("Updated " + _this.label, 'success', 'growl-top-right');
        }
      };
    })(this));
  }
});

Template.edit_date_field.events({
  'blur #date_field': function(e, t) {
    var date_value, obj;
    date_value = e.currentTarget.value;
    console.log(date_value);
    return Docs.update(FlowRouter.getParam('doc_id'), {
      $set: (
        obj = {},
        obj["" + this.key] = date_value,
        obj
      )
    }, (function(_this) {
      return function(err, res) {
        if (err) {
          return Bert.alert("Error Updating " + _this.label + ": " + err.reason, 'danger', 'growl-top-right');
        } else {
          return Bert.alert("Updated " + _this.label, 'success', 'growl-top-right');
        }
      };
    })(this));
  }
});

Template.edit_text_field.events({
  'change #text_field': function(e, t) {
    var obj, text_value;
    text_value = e.currentTarget.value;
    return Docs.update(FlowRouter.getParam('doc_id'), {
      $set: (
        obj = {},
        obj["" + this.key] = text_value,
        obj
      )
    }, (function(_this) {
      return function(err, res) {
        if (err) {
          return Bert.alert("Error Updating " + _this.label + ": " + err.reason, 'danger', 'growl-top-right');
        } else {
          return Bert.alert("Updated " + _this.label, 'success', 'growl-top-right');
        }
      };
    })(this));
  }
});

Template.edit_profile_text_field.events({
  'change #text_field': function(e, t) {
    var obj, text_value;
    text_value = e.currentTarget.value;
    return Meteor.users.update(FlowRouter.getParam('user_id'), {
      $set: (
        obj = {},
        obj["profile." + this.key] = text_value,
        obj
      )
    }, (function(_this) {
      return function(err, res) {
        if (err) {
          return Bert.alert("Error Updating " + _this.label + ": " + err.reason, 'danger', 'growl-top-right');
        } else {
          return Bert.alert("Updated " + _this.label, 'success', 'growl-top-right');
        }
      };
    })(this));
  }
});

Template.complete.events({
  'click #mark_complete': function(e, t) {
    return Docs.update(this._id, {
      $set: {
        complete: true
      }
    });
  },
  'click #mark_incomplete': function(e, t) {
    return Docs.update(this._id, {
      $set: {
        complete: false
      }
    });
  }
});

Template.complete.helpers({
  complete_class: function() {
    if (this.complete) {
      return 'green';
    } else {
      return 'basic';
    }
  },
  incomplete_class: function() {
    if (this.complete) {
      return 'basic';
    } else {
      return 'red';
    }
  }
});

Template.toggle_follow.helpers({
  is_following: function() {
    var ref, ref1;
    if ((ref = Meteor.user()) != null ? ref.following_ids : void 0) {
      return ref1 = this._id, indexOf.call(Meteor.user().following_ids, ref1) >= 0;
    }
  }
});

Template.toggle_follow.events({
  'click #follow': function(e, t) {
    return Meteor.users.update(Meteor.userId(), {
      $addToSet: {
        following_ids: this._id
      }
    });
  },
  'click #unfollow': function(e, t) {
    return Meteor.users.update(Meteor.userId(), {
      $pull: {
        following_ids: this._id
      }
    });
  }
});

Template.toggle_boolean.events({
  'click #make_featured': function() {
    return Docs.update(FlowRouter.getParam('doc_id'), {
      $set: {
        featured: true
      }
    });
  },
  'click #make_unfeatured': function() {
    return Docs.update(FlowRouter.getParam('doc_id'), {
      $set: {
        featured: false
      }
    });
  }
});

Template.edit_array_field.events({
  'keyup .new_entry': function(e, t) {
    var obj, val;
    e.preventDefault();
    val = $(e.currentTarget).closest('.new_entry').val().toLowerCase().trim();
    switch (e.which) {
      case 13:
        if (val.length !== 0) {
          Docs.update(FlowRouter.getParam('doc_id'), {
            $addToSet: (
              obj = {},
              obj["" + this.key] = val,
              obj
            )
          });
          return $(e.currentTarget).closest('.new_entry').val('');
        }
    }
  },
  'click .doc_tag': function(e, t) {
    var obj, tag;
    tag = this.valueOf();
    Docs.update(FlowRouter.getParam('doc_id'), {
      $pull: (
        obj = {},
        obj["" + (Template.parentData(0).key)] = tag,
        obj
      )
    });
    return t.$('.new_entry').val(tag);
  }
});

Template.edit_array_field.helpers;

// ---
// generated by coffee-script 1.9.2