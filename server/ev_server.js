Meteor.methods({
  sync_ev_users: function() {
    var found_user, i, len, new_user_id, res, results, self, split_res, split_user, user_string;
    self = this;
    res = HTTP.call('GET', "http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action", {
      headers: {
        "User-Agent": "Meteor/1.0"
      },
      params: {
        user_id: 'JAN-HUB',
        password: 'j@NhU8',
        statevar: 'get_users'
      }
    });
    console.dir(res.content);
    split_res = res.content.split('\r\n');
    results = [];
    for (i = 0, len = split_res.length; i < len; i++) {
      user_string = split_res[i];
      split_user = user_string.split('|');
      console.log(split_user);
      if (split_user[0]) {
        found_user = Docs.findOne({
          type: 'user',
          user_id: split_user[0]
        });
        if (!found_user) {
          new_user_id = Docs.insert({
            type: 'user',
            user_id: split_user[0],
            user_first_name: split_user[1],
            user_last_name: split_user[2]
          });
          results.push(console.log('added user doc id:', new_user_id));
        } else {
          results.push(console.log('existing user doc:', found_user._id));
        }
      } else {
        results.push(void 0);
      }
    }
    return results;
  },
  get_user_info: function(username) {
    var i, key_value_string, len, res, save_json, split_key_value, split_res, user_doc;
    user_doc = Meteor.users.findOne({
      username: username
    });
    res = HTTP.call('GET', "http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action", {
      headers: {
        "User-Agent": "Meteor/1.0"
      },
      params: {
        user_id: 'JAN-HUB',
        password: 'j@NhU8',
        statevar: 'get_user_info',
        login_id: username
      }
    });
    if (res.content.includes("denied")) {
      console.log('no');
      throw new Meteor.Error('permission denied', "Permission denied to get user");
    } else {
      console.log('doesnt include');
    }
    split_res = res.content.split('\r\n');
    save_json = {};
    for (i = 0, len = split_res.length; i < len; i++) {
      key_value_string = split_res[i];
      split_key_value = key_value_string.split('|');
      save_json["" + split_key_value[0]] = split_key_value[1];
    }
    return Meteor.users.update(user_doc._id, {
      $set: {
        ev: save_json
      }
    });
  },
  get_history: function() {
    var res;
    res = HTTP.call('GET', "http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action", {
      headers: {
        "User-Agent": "Meteor/1.0"
      },
      params: {
        user_id: 'JAN-HUB',
        password: 'j@NhU8',
        statevar: 'history',
        cutoff: moment().subtract(100, 'days').calendar()
      }
    });
    return xml2js.parseString(res.content, {
      explicitArray: false,
      emptyTag: '',
      ignoreAttrs: true,
      trim: true
    }, (function(_this) {
      return function(err, json_result) {
        var doc, existing_history_doc, i, len, ref, results;
        if (err) {
          console.error('errors', err);
        } else {

        }
        if (json_result.HISTORY.PROBLEM_RECORD) {
          ref = json_result.HISTORY.PROBLEM_RECORD;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            doc = ref[i];
            existing_history_doc = Docs.findOne({
              type: 'history',
              "ev.TIMESTAMP": doc.TIMESTAMP
            });
            if (existing_history_doc) {
              results.push(console.log("existing history " + existing_history_doc.ev.TIMESTAMP));
            } else {
              results.push(Docs.insert({
                type: 'history',
                ev: doc
              }));
            }
          }
          return results;
        }
      };
    })(this));
  },
  get_jp_id: function(jp_id) {
    var includes_boolean, res;
    res = HTTP.call('GET', "http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action", {
      headers: {
        "User-Agent": "Meteor/1.0"
      },
      params: {
        user_id: 'JAN-HUB',
        password: 'j@NhU8',
        statevar: 'get',
        id: jp_id
      }
    });
    includes_boolean = res.content.includes("does not exist");
    if (includes_boolean) {
      throw new Meteor.Error('no user', "JP Id " + jp_id + " does not exist");
    } else {
      return xml2js.parseString(res.content, {
        explicitArray: false,
        emptyTag: '',
        ignoreAttrs: true,
        trim: true
      }, (function(_this) {
        return function(err, json_result) {
          var existing_jpid, new_jpid, updatedList;
          if (err) {
            return console.error('errors', err);
          } else {
            updatedList = JSON.stringify(json_result.PROBLEM_RECORD, function(key, value) {
              if (value === void 0) {
                return '';
              } else {
                return value;
              }
            });
            existing_jpid = Docs.findOne({
              type: 'jpid',
              jpid: jp_id
            });
            if (existing_jpid) {
              return Docs.update(existing_jpid, {
                $set: {
                  ev: json_result.PROBLEM_RECORD
                }
              });
            } else {
              return new_jpid = Docs.insert({
                type: 'jpid',
                jpid: jp_id,
                ev: json_result.PROBLEM_RECORD
              });
            }
          }
        };
      })(this));
    }
  },
  search_ev: function(query) {
    var res;
    res = HTTP.call('GET', "http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action", {
      headers: {
        "User-Agent": "Meteor/1.0"
      },
      params: {
        user_id: 'JAN-HUB',
        password: 'j@NhU8',
        statevar: 'search',
        page_length: 100,
        record_start: 1,
        record_count: 100,
        username_display: 'ID',
        timestamp: "'2018-06-05'-'2018-07-30'"
      }
    });
    return xml2js.parseString(res.content, {
      explicitArray: false,
      emptyTag: '',
      ignoreAttrs: true,
      trim: true
    }, (function(_this) {
      return function(err, json_result) {
        var doc, existing_search_history_doc, i, len, new_search_history_doc, ref, result, results;
        if (err) {
          return console.error('errors', err);
        } else {
          result = json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD;
          ref = json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            doc = ref[i];
            existing_search_history_doc = Docs.findOne({
              type: 'search_history_doc',
              "ev.ID": doc.ID
            });
            if (existing_search_history_doc) {
              results.push(console.log("existing search history doc " + existing_search_history_doc.ev.ID));
            } else {
              new_search_history_doc = Docs.insert({
                type: 'search_history_doc',
                ev: doc
              });
              results.push(console.log("added " + doc.ID));
            }
          }
          return results;
        }
      };
    })(this));
  },
  get_all_franchisees: function() {
    var res;
    console.log('starting franchisee sync');
    res = HTTP.call('GET', "http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action", {
      headers: {
        "User-Agent": "Meteor/1.0"
      },
      params: {
        user_id: 'JAN-HUB',
        password: 'j@NhU8',
        statevar: 'run_report',
        username_display: 'ID',
        api_reverse_lookup: 'NO',
        id: '48297',
        page_length: '10000',
        record_start: '55000',
        record_count: '10000'
      }
    });
    return xml2js.parseString(res.content, {
      explicitArray: false,
      emptyTag: '',
      ignoreAttrs: true,
      trim: true
    }, (function(_this) {
      return function(err, json_result) {
        var doc, existing_franchisee, i, len, new_franchisee_doc, ref, results;
        if (err) {
          console.error('errors', err);
        } else {

        }
        if (json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD) {
          ref = json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            doc = ref[i];
            existing_franchisee = Docs.findOne({
              type: 'franchisee',
              "ev.ID": doc.ID
            });
            if (existing_franchisee) {
              console.log("existing franchisee " + existing_franchisee.ev.FRANCHISEE);
              results.push(Docs.update(existing_franchisee._id, {
                $set: {
                  ev: doc
                }
              }));
            } else {
              new_franchisee_doc = Docs.insert({
                type: 'franchisee',
                ev: doc
              });
              results.push(console.log("added " + doc.SHORT_NAME));
            }
          }
          return results;
        }
      };
    })(this));
  },
  sync_services: function() {
    var res;
    res = HTTP.call('GET', "http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action", {
      headers: {
        "User-Agent": "Meteor/1.0"
      },
      params: {
        user_id: 'JAN-HUB',
        password: 'j@NhU8',
        statevar: 'run_report',
        username_display: 'ID',
        api_reverse_lookup: 'NO',
        id: '47857',
        page_length: '7500',
        record_start: '1',
        record_count: '7500'
      }
    });
    return xml2js.parseString(res.content, {
      explicitArray: false,
      emptyTag: '',
      ignoreAttrs: true,
      trim: true
    }, (function(_this) {
      return function(err, json_result) {
        var doc, existing_service_doc, i, len, new_special_service_doc, ref, results;
        if (err) {
          console.error('errors', err);
        } else {

        }
        if (json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD) {
          ref = json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            doc = ref[i];
            console.log(doc);
            existing_service_doc = Docs.findOne({
              type: 'special_service',
              jpid: doc.ID
            });
            if (existing_service_doc) {
              console.log("existing special_service " + existing_service_doc.ev.FRANCHISEE);
              results.push(Docs.update(existing_service_doc._id, {
                $set: {
                  ev: doc
                }
              }));
            } else {
              new_special_service_doc = Docs.insert({
                type: 'special_service',
                jpid: doc.ID,
                ev: doc
              });
              results.push(console.log("added " + doc.ID));
            }
          }
          return results;
        }
      };
    })(this));
  },
  sync_offices: function() {
    var res;
    res = HTTP.call('GET', "http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action", {
      headers: {
        "User-Agent": "Meteor/1.0"
      },
      params: {
        user_id: 'JAN-HUB',
        password: 'j@NhU8',
        statevar: 'run_report',
        username_display: 'ID',
        api_reverse_lookup: 'NO',
        id: '48307',
        page_length: '250',
        record_start: '1',
        record_count: '250'
      }
    });
    return xml2js.parseString(res.content, {
      explicitArray: false,
      emptyTag: '',
      ignoreAttrs: true,
      trim: true
    }, (function(_this) {
      return function(err, json_result) {
        var doc, existing_office_doc, i, len, new_office_doc, ref, results;
        if (err) {
          console.error('errors', err);
        } else {

        }
        if (json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD) {
          ref = json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            doc = ref[i];
            console.log(doc);
            existing_office_doc = Docs.findOne({
              type: 'office',
              "ev.ID": doc.ID
            });
            if (existing_office_doc) {
              console.log("existing office " + existing_office_doc.ev.MASTER_LICENSEE);
              results.push(Docs.update(existing_office_doc._id, {
                $set: {
                  ev: doc
                }
              }));
            } else {
              new_office_doc = Docs.insert({
                type: 'office',
                ev: doc
              });
              results.push(console.log("added " + doc.ID));
            }
          }
          return results;
        }
      };
    })(this));
  },
  sync_customers: function() {
    var res;
    console.log('starting customer sync');
    res = HTTP.call('GET', "http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action", {
      headers: {
        "User-Agent": "Meteor/1.0"
      },
      params: {
        user_id: 'JAN-HUB',
        password: 'j@NhU8',
        statevar: 'run_report',
        username_display: 'ID',
        api_reverse_lookup: 'NO',
        id: '48302',
        page_length: '40000',
        record_start: '1',
        record_count: '40000'
      }
    });
    return xml2js.parseString(res.content, {
      explicitArray: false,
      emptyTag: '',
      ignoreAttrs: true,
      trim: true
    }, (function(_this) {
      return function(err, json_result) {
        var doc, existing_customer_doc, i, len, new_customer_doc, ref, results;
        if (err) {
          console.error('errors', err);
        } else {

        }
        if (json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD) {
          ref = json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            doc = ref[i];
            console.log(doc);
            existing_customer_doc = Docs.findOne({
              type: 'customer',
              "ev.CUST_NAME": doc.CUST_NAME
            });
            if (existing_customer_doc) {
              console.log("existing customer " + existing_customer_doc.ev.CUST_NAME);
              Docs.update(existing_customer_doc._id, {
                $set: {
                  ev: doc
                }
              });
            }
            if (!existing_customer_doc) {
              new_customer_doc = Docs.insert({
                type: 'customer',
                ev: doc
              });
              results.push(console.log("added " + doc.CUST_NAME));
            } else {
              results.push(void 0);
            }
          }
          return results;
        }
      };
    })(this));
  },
  sync_ny_statements: function() {
    var res;
    console.log('starting ny statement sync');
    res = HTTP.call('GET', "http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action", {
      headers: {
        "User-Agent": "Meteor/1.0"
      },
      params: {
        user_id: 'JAN-HUB',
        password: 'j@NhU8',
        statevar: 'run_report',
        username_display: 'ID',
        api_reverse_lookup: 'NO',
        id: '48927',
        page_length: '500',
        record_start: '1',
        record_count: '500'
      }
    });
    return xml2js.parseString(res.content, {
      explicitArray: false,
      emptyTag: '',
      ignoreAttrs: true,
      trim: true
    }, (function(_this) {
      return function(err, json_result) {
        var doc, existing_statment_doc, i, len, new_statment_doc, ref, results;
        if (err) {
          console.error('errors', err);
        } else {

        }
        if (json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD) {
          ref = json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            doc = ref[i];
            console.log(doc);
            existing_statment_doc = Docs.findOne({
              type: 'statment',
              "ev.CUST_NAME": doc.CUST_NAME
            });
            if (existing_statment_doc) {
              console.log("existing statment " + existing_statment_doc.ev.CUST_NAME);
              Docs.update(existing_statment_doc._id, {
                $set: {
                  ev: doc
                }
              });
            }
            if (!existing_statment_doc) {
              new_statment_doc = Docs.insert({
                type: 'statment',
                ev: doc
              });
              results.push(console.log("added " + doc.CUST_NAME));
            } else {
              results.push(void 0);
            }
          }
          return results;
        }
      };
    })(this));
  },
  list_attachments: function(id) {
    var res;
    console.log('starting ny statement sync');
    res = HTTP.call('GET', "http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action", {
      headers: {
        "User-Agent": "Meteor/1.0"
      },
      params: {
        user_id: 'JAN-HUB',
        password: 'j@NhU8',
        statevar: 'list_attachment',
        username_display: 'ID',
        id: id
      }
    });
    return console.log(res.content);
  }
});

// ---
// generated by coffee-script 1.9.2