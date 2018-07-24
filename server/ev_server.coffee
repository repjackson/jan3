Meteor.methods
  sync_ev_users: ->
    found_user = undefined
    i = undefined
    len = undefined
    new_user_id = undefined
    res = undefined
    results = undefined
    self = undefined
    split_res = undefined
    split_user = undefined
    user_string = undefined
    self = this
    res = HTTP.call('GET', 'http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action',
      headers: 'User-Agent': 'Meteor/1.0'
      params:
        user_id: 'JAN-HUB'
        password: 'j@NhU8'
        statevar: 'get_users')
    console.dir res.content
    split_res = res.content.split('\u000d\n')
    results = []
    i = 0
    len = split_res.length
    while i < len
      user_string = split_res[i]
      split_user = user_string.split('|')
      console.log split_user
      if split_user[0]
        found_user = Docs.findOne(
          type: 'user'
          user_id: split_user[0])
        if !found_user
          new_user_id = Docs.insert(
            type: 'user'
            user_id: split_user[0]
            user_first_name: split_user[1]
            user_last_name: split_user[2])
          results.push console.log('added user doc id:', new_user_id)
        else
          results.push console.log('existing user doc:', found_user._id)
      else
        results.push undefined
      i++
    results
  get_user_info: (username) ->
    i = undefined
    key_value_string = undefined
    len = undefined
    res = undefined
    save_json = undefined
    split_key_value = undefined
    split_res = undefined
    user_doc = undefined
    user_doc = Meteor.users.findOne(username: username)
    res = HTTP.call('GET', 'http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action',
      headers: 'User-Agent': 'Meteor/1.0'
      params:
        user_id: 'JAN-HUB'
        password: 'j@NhU8'
        statevar: 'get_user_info'
        login_id: username)
    if res.content.includes('denied')
      console.log 'no'
      throw new (Meteor.Error)('permission denied', 'Permission denied to get user')
    else
      console.log 'doesnt include'
    split_res = res.content.split('\u000d\n')
    save_json = {}
    i = 0
    len = split_res.length
    while i < len
      key_value_string = split_res[i]
      split_key_value = key_value_string.split('|')
      save_json['' + split_key_value[0]] = split_key_value[1]
      i++
    Meteor.users.update user_doc._id, $set: ev: save_json
  get_history: ->
    res = undefined
    res = HTTP.call('GET', 'http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action',
      headers: 'User-Agent': 'Meteor/1.0'
      params:
        user_id: 'JAN-HUB'
        password: 'j@NhU8'
        statevar: 'history'
        cutoff: moment().subtract(100, 'days').calendar())
    xml2js.parseString res.content, {
      explicitArray: false
      emptyTag: ''
      ignoreAttrs: true
      trim: true
    }, ((_this) ->
      (err, json_result) ->
        doc = undefined
        existing_history_doc = undefined
        i = undefined
        len = undefined
        ref = undefined
        results = undefined
        if err
          console.error 'errors', err
        else
        if json_result.HISTORY.PROBLEM_RECORD
          ref = json_result.HISTORY.PROBLEM_RECORD
          results = []
          i = 0
          len = ref.length
          while i < len
            doc = ref[i]
            existing_history_doc = Docs.findOne(
              type: 'history'
              'ev.TIMESTAMP': doc.TIMESTAMP)
            if existing_history_doc
              results.push console.log('existing history ' + existing_history_doc.ev.TIMESTAMP)
            else
              results.push Docs.insert(
                type: 'history'
                ev: doc)
            i++
          return results
        return
    )(this)
  get_jp_id: (jp_id) ->
    includes_boolean = undefined
    res = undefined
    res = HTTP.call('GET', 'http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action',
      headers: 'User-Agent': 'Meteor/1.0'
      params:
        user_id: 'JAN-HUB'
        password: 'j@NhU8'
        statevar: 'get'
        id: jp_id)
    includes_boolean = res.content.includes('does not exist')
    if includes_boolean
      throw new (Meteor.Error)('no user', 'JP Id ' + jp_id + ' does not exist')
    else
      return xml2js.parseString(res.content, {
        explicitArray: false
        emptyTag: ''
        ignoreAttrs: true
        trim: true
      }, ((_this) ->
        (err, json_result) ->
          existing_jpid = undefined
          new_jpid = undefined
          updatedList = undefined
          if err
            console.error 'errors', err
          else
            updatedList = JSON.stringify(json_result.PROBLEM_RECORD, (key, value) ->
              if value == undefined
                ''
              else
                value
            )
            existing_jpid = Docs.findOne(
              type: 'jpid'
              jpid: jp_id)
            if existing_jpid
              Docs.update existing_jpid, $set: ev: json_result.PROBLEM_RECORD
            else
              new_jpid = Docs.insert(
                type: 'jpid'
                jpid: jp_id
                ev: json_result.PROBLEM_RECORD)
      )(this))
    return
  search_ev: (query) ->
    res = undefined
    res = HTTP.call('GET', 'http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action',
      headers: 'User-Agent': 'Meteor/1.0'
      params:
        user_id: 'JAN-HUB'
        password: 'j@NhU8'
        statevar: 'search'
        page_length: 100
        record_start: 1
        record_count: 100
        username_display: 'ID'
        timestamp: '\'2018-07-05\'-\'2018-07-30\'')
    xml2js.parseString res.content, {
      explicitArray: false
      emptyTag: ''
      ignoreAttrs: true
      trim: true
    }, ((_this) ->
      (err, json_result) ->
        doc = undefined
        existing_search_history_doc = undefined
        i = undefined
        len = undefined
        new_search_history_doc = undefined
        ref = undefined
        result = undefined
        results = undefined
        if err
          console.error 'errors', err
        else
          result = json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
          ref = json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
          results = []
          i = 0
          len = ref.length
          while i < len
            doc = ref[i]
            existing_search_history_doc = Docs.findOne(
              type: 'search_history_doc'
              'ev.ID': doc.ID)
            if existing_search_history_doc
              results.push console.log('existing search history doc ' + existing_search_history_doc.ev.ID)
            else
              new_search_history_doc = Docs.insert(
                type: 'search_history_doc'
                ev: doc)
              results.push console.log('added ' + doc.ID)
            i++
          results
    )(this)
  get_all_franchisees: ->
    res = undefined
    console.log 'starting franchisee sync'
    res = HTTP.call('GET', 'http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action',
      headers: 'User-Agent': 'Meteor/1.0'
      params:
        user_id: 'JAN-HUB'
        password: 'j@NhU8'
        statevar: 'run_report'
        username_display: 'ID'
        api_reverse_lookup: 'NO'
        id: '48297'
        page_length: '10000'
        record_start: '55000'
        record_count: '10000')
    xml2js.parseString res.content, {
      explicitArray: false
      emptyTag: ''
      ignoreAttrs: true
      trim: true
    }, ((_this) ->
      (err, json_result) ->
        doc = undefined
        existing_franchisee = undefined
        i = undefined
        len = undefined
        new_franchisee_doc = undefined
        ref = undefined
        results = undefined
        if err
          console.error 'errors', err
        else
        if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
          ref = json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
          results = []
          i = 0
          len = ref.length
          while i < len
            doc = ref[i]
            existing_franchisee = Docs.findOne(
              type: 'franchisee'
              'ev.ID': doc.ID)
            if existing_franchisee
              console.log 'existing franchisee ' + existing_franchisee.ev.FRANCHISEE
              results.push Docs.update(existing_franchisee._id, $set: ev: doc)
            else
              new_franchisee_doc = Docs.insert(
                type: 'franchisee'
                ev: doc)
              results.push console.log('added ' + doc.SHORT_NAME)
            i++
          return results
        return
    )(this)
  sync_services: ->
    res = undefined
    res = HTTP.call('GET', 'http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action',
      headers: 'User-Agent': 'Meteor/1.0'
      params:
        user_id: 'JAN-HUB'
        password: 'j@NhU8'
        statevar: 'run_report'
        username_display: 'ID'
        api_reverse_lookup: 'NO'
        id: '47857'
        page_length: '7500'
        record_start: '1'
        record_count: '7500')
    xml2js.parseString res.content, {
      explicitArray: false
      emptyTag: ''
      ignoreAttrs: true
      trim: true
    }, ((_this) ->
      (err, json_result) ->
        doc = undefined
        existing_service_doc = undefined
        i = undefined
        len = undefined
        new_special_service_doc = undefined
        ref = undefined
        results = undefined
        if err
          console.error 'errors', err
        else
        if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
          ref = json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
          results = []
          i = 0
          len = ref.length
          while i < len
            doc = ref[i]
            console.log doc
            existing_service_doc = Docs.findOne(
              type: 'special_service'
              jpid: doc.ID)
            if existing_service_doc
              console.log 'existing special_service ' + existing_service_doc.ev.FRANCHISEE
              results.push Docs.update(existing_service_doc._id, $set: ev: doc)
            else
              new_special_service_doc = Docs.insert(
                type: 'special_service'
                jpid: doc.ID
                ev: doc)
              results.push console.log('added ' + doc.ID)
            i++
          return results
        return
    )(this)
  sync_offices: ->
    res = undefined
    res = HTTP.call('GET', 'http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action',
      headers: 'User-Agent': 'Meteor/1.0'
      params:
        user_id: 'JAN-HUB'
        password: 'j@NhU8'
        statevar: 'run_report'
        username_display: 'ID'
        api_reverse_lookup: 'NO'
        id: '48307'
        page_length: '250'
        record_start: '1'
        record_count: '250')
    xml2js.parseString res.content, {
      explicitArray: false
      emptyTag: ''
      ignoreAttrs: true
      trim: true
    }, ((_this) ->
      (err, json_result) ->
        doc = undefined
        existing_office_doc = undefined
        i = undefined
        len = undefined
        new_office_doc = undefined
        ref = undefined
        results = undefined
        if err
          console.error 'errors', err
        else
        if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
          ref = json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
          results = []
          i = 0
          len = ref.length
          while i < len
            doc = ref[i]
            console.log doc
            existing_office_doc = Docs.findOne(
              type: 'office'
              'ev.ID': doc.ID)
            if existing_office_doc
              console.log 'existing office ' + existing_office_doc.ev.MASTER_LICENSEE
              results.push Docs.update(existing_office_doc._id, $set: ev: doc)
            else
              new_office_doc = Docs.insert(
                type: 'office'
                ev: doc)
              results.push console.log('added ' + doc.ID)
            i++
          return results
        return
    )(this)
  sync_customers: ->
    res = undefined
    console.log 'starting customer sync'
    res = HTTP.call('GET', 'http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action',
      headers: 'User-Agent': 'Meteor/1.0'
      params:
        user_id: 'JAN-HUB'
        password: 'j@NhU8'
        statevar: 'run_report'
        username_display: 'ID'
        api_reverse_lookup: 'NO'
        id: '48302'
        page_length: '40000'
        record_start: '40000'
        record_count: '40000')
    xml2js.parseString res.content, {
      explicitArray: false
      emptyTag: ''
      ignoreAttrs: true
      trim: true
    }, ((_this) ->
      (err, json_result) ->
        doc = undefined
        existing_customer_doc = undefined
        i = undefined
        len = undefined
        new_customer_doc = undefined
        ref = undefined
        results = undefined
        if err
          console.error 'errors', err
        else
        if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
          ref = json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
          results = []
          i = 0
          len = ref.length
          while i < len
            doc = ref[i]
            console.log doc
            existing_customer_doc = Docs.findOne(
              type: 'customer'
              'ev.CUST_NAME': doc.CUST_NAME)
            if existing_customer_doc
              console.log 'existing customer ' + existing_customer_doc.ev.CUST_NAME
              Docs.update existing_customer_doc._id, $set: ev: doc
            if !existing_customer_doc
              new_customer_doc = Docs.insert(
                type: 'customer'
                ev: doc)
              results.push console.log('added ' + doc.CUST_NAME)
            else
              results.push undefined
            i++
          return results
        return
    )(this)
  # sync_ny_statements: ->
  #   res = undefined
  #   console.log 'starting ny statement sync'
  #   res = HTTP.call('GET', 'http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action',
  #     headers: 'User-Agent': 'Meteor/1.0'
  #     params:
  #       user_id: 'JAN-HUB'
  #       password: 'j@NhU8'
  #       statevar: 'run_report'
  #       username_display: 'ID'
  #       api_reverse_lookup: 'NO'
  #       id: '48927'
  #       page_length: '500'
  #       record_start: '1'
  #       record_count: '500')
  #   xml2js.parseString res.content, {
  #     explicitArray: false
  #     emptyTag: ''
  #     ignoreAttrs: true
  #     trim: true
  #   }, ((_this) ->
  #     (err, json_result) ->
  #       doc = undefined
  #       existing_statment_doc = undefined
  #       i = undefined
  #       len = undefined
  #       new_statment_doc = undefined
  #       ref = undefined
  #       results = undefined
  #       if err
  #         console.error 'errors', err
  #       else
  #       if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
  #         ref = json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
  #         results = []
  #         i = 0
  #         len = ref.length
  #         while i < len
  #           doc = ref[i]
  #           console.log doc
  #           existing_statment_doc = Docs.findOne(
  #             type: 'statment'
  #             'ev.CUST_NAME': doc.CUST_NAME)
  #           if existing_statment_doc
  #             console.log 'existing statment ' + existing_statment_doc.ev.CUST_NAME
  #             Docs.update existing_statment_doc._id, $set: ev: doc
  #           if !existing_statment_doc
  #             new_statment_doc = Docs.insert(
  #               type: 'statment'
  #               ev: doc)
  #             results.push console.log('added ' + doc.CUST_NAME)
  #           else
  #             results.push undefined
  #           i++
  #         return results
  #       return
  #   )(this)
  list_attachments: (id) ->
    res = undefined
    console.log 'starting ny statement sync'
    res = HTTP.call('GET', 'http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action',
      headers: 'User-Agent': 'Meteor/1.0'
      params:
        user_id: 'JAN-HUB'
        password: 'j@NhU8'
        statevar: 'list_attachment'
        username_display: 'ID'
        id: id)
    console.log res.content
