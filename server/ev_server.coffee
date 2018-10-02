Meteor.methods
    call_lodestar: ->
        HTTP.call 'GET',"https://sandbox.lodestarbpm.com/test/api-test.php", (err,res)->
            if err then console.error err
            else
                body = res.content
                json = JSON.parse body



    sync_ev_users: ()->
        self = @

        res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
            headers: "User-Agent": "Meteor/1.0"
            params:
                user_id:'JAN-HUB'
                password:'j@NhU8'
                statevar: 'get_users'
                # disabled: [Y|N|
                # filter: pattern
                # filter_type: "ID"
        # console.dir res.content
        split_res = res.content.split '\r\n'

        for user_string in split_res
            split_user = user_string.split '|'
            if split_user[0]
                found_user =
                    Meteor.users.findOne
                        username:split_user[0]
                if found_user
                    Meteor.call 'get_user_info', split_user[0]
                else
                    options = {}
                    options.username = split_user[0]
                    options.first_name = split_user[1]
                    options.last_name = split_user[2]
                    result = Accounts.createUser(options)
                    if result
                        Meteor.call 'get_user_info', options.username

    get_user_info: (username)->
        # users_cursor = Meteor.users.find({}).fetch()
        # for each_user in users_cursor

        user_doc = Meteor.users.findOne username:username
        # if each_user.ev.LAST_NAME
        # else
        res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
            headers: "User-Agent": "Meteor/1.0"
            params:
                user_id:'JAN-HUB'
                password:'j@NhU8'
                statevar:'get_user_info'
                login_id: username
        if res.content.includes("denied")
            throw new Meteor.Error('permission denied', "Permission denied to get user")
        else
            split_res = res.content.split '\r\n'
            console.log split_res
            save_json = {}
            for key_value_string in split_res
                split_key_value = key_value_string.split '|'
                save_json["#{split_key_value[0]}"] = split_key_value[1]
            if user_doc
                Meteor.users.update user_doc._id,
                    $set:
                        ev: save_json

            else
                # Meteor.users.insert

    get_jp_id: (jp_id)->
        res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
            headers: "User-Agent": "Meteor/1.0"
            params:
                user_id:'JAN-HUB'
                password:'j@NhU8'
                statevar:'get'
                id:jp_id
        includes_boolean = res.content.includes("does not exist")
        if includes_boolean
            throw new Meteor.Error('no user', "JP Id #{jp_id} does not exist")
        else
            xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
                if err then console.error('errors',err)
                else
                    # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
                    # console.dir json_result.PROBLEM_RECORD
                    updatedList = JSON.stringify(json_result.PROBLEM_RECORD, (key, value) ->
                        if value == undefined then '' else value
                    )
                    console.dir updatedList
                    # existing_jpid =
                    #     Docs.findOne
                    #         type: 'jpid'
                    #         jpid: jp_id
                    # if existing_jpid
                    #     Docs.update existing_jpid,
                    #         $set:
                    #             ev: json_result.PROBLEM_RECORD
                    # else
                    #     new_jpid = Docs.insert
                    #         type:'jpid'
                    #         jpid:jp_id
                    #         ev: json_result.PROBLEM_RECORD

    search_ev: (query)->
        res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
            headers:"User-Agent": "Meteor/1.0"
            params:
                user_id:'JAN-HUB'
                password:'j@NhU8'
                statevar: 'search'
                page_length: 10
                record_start: 1
                record_count: 10
                username_display: 'ID'
                area: 'Customer'
                # DATE_CREATED: "'2018-07-23'-'2018-07-30'"
                # timestamp: "'2018-07-23'-'2018-07-30'"
        # xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
        #     if err then console.error('errors',err)
        #     else
        #         result = json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
        #         # console.dir result
        #         for doc in json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
        #             # if doc.AREA is 'Customer'
        #             # if doc.AREA in ['Franchisee','Customer']
        #             # if (doc.MASTER_LICENSEE is "Jan-Pro of Upstate New York") or (doc.AREA is 'Customer')
        #                 # doc.type = 'customer'
        #             existing_search_history_doc =
        #                 Docs.findOne
        #                     type: 'search_history_doc'
        #                     "ev.ID": doc.ID
        #             if existing_search_history_doc
        #                 # Docs.update existing_search_history_doc._id,
        #                 #     $set: ev: doc
        #             else
        #                 new_search_history_doc = Docs.insert
        #                     type:'search_history_doc'
        #                     ev: doc
        #             # else continue

    get_all_franchisees: () ->
        res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
            headers:"User-Agent": "Meteor/1.0"
            params:
                user_id:'JAN-HUB'
                password:'j@NhU8'
                statevar:'run_report'
                username_display:'ID'
                api_reverse_lookup:'NO'
                id:'48297'
                page_length:'10000'
                record_start:'55000'
                record_count:'10000'
        # return res.content
        xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
            if err then console.error('errors',err)
            else
                # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
                # console.dir json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1..5]
                # new_id = Docs.insert
            if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                for doc in json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                    # doc.type = 'customer'
                    existing_franchisee =
                        Docs.findOne
                            type: 'franchisee'
                            "ev.ID": doc.ID
                    if existing_franchisee
                        Docs.update existing_franchisee._id,
                            $set:
                                ev: doc
                    else
                        new_franchisee_doc = Docs.insert
                            type:'franchisee'
                            ev: doc

    sync_services: () ->
        res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
            headers:"User-Agent": "Meteor/1.0"
            params:
                user_id:'JAN-HUB'
                password:'j@NhU8'
                statevar:'run_report'
                username_display:'ID'
                api_reverse_lookup:'NO'
                id:'47857'
                page_length:'7500'
                record_start:'1'
                record_count:'7500'
        # return res.content
        xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
            if err then console.error('errors',err)
            else
        #         # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
        #         # console.dir json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1..5]
        #         # new_id = Docs.insert
            if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                for doc in json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                    # doc.type = 'customer'
                    existing_service_doc =
                        Docs.findOne
                            type: 'special_service'
                            jpid: doc.ID
                    if existing_service_doc
                        Docs.update existing_service_doc._id,
                            $set:
                                ev: doc
                    else
                        new_special_service_doc = Docs.insert
                            type:'special_service'
                            jpid: doc.ID
                            ev: doc

    get_ev_finance: () ->
        res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
            headers:"User-Agent": "Meteor/1.0"
            params:
                user_id:'JAN-HUB'
                password:'j@NhU8'
                statevar:'run_report'
                username_display:'ID'
                api_reverse_lookup:'NO'
                id:'49467'
                page_length:'10000'
                record_start:'10000'
                record_count:'10000'
        xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
            if err then console.error('errors',err)
            else
                # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
                console.dir json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1..5]
                # new_id = Docs.insert
            if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                for doc in json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                    # doc.type = 'customer'
                    existing_finance_doc =
                        Docs.findOne "ev.BILL_QB_INVOICE": doc.BILL_QB_INVOICE
                    if existing_finance_doc
                        Docs.update existing_finance_doc._id,
                            $set:
                                ev: doc
                    else
                        new_finance_doc = Docs.insert
                            type:'finance'
                            ev: doc

    sync_offices: () ->
        res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
            headers:"User-Agent": "Meteor/1.0"
            params:
                user_id:'JAN-HUB'
                password:'j@NhU8'
                statevar:'run_report'
                username_display:'ID'
                api_reverse_lookup:'NO'
                id:'48307'
                page_length:'250'
                record_start:'1'
                record_count:'250'
        # return res.content
        xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
            if err then console.error('errors',err)
            else
        #         # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
        #         # console.dir json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1..5]
        #         # new_id = Docs.insert
            if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                for doc in json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                    # doc.type = 'customer'
                    existing_office_doc =
                        Docs.findOne
                            type: 'office'
                            "ev.ID": doc.ID
                    if existing_office_doc
                        Docs.update existing_office_doc._id,
                            $set: ev: doc
                    else
                        new_office_doc = Docs.insert
                            type:'office'
                            ev: doc

    sync_customers: () ->
        res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
            headers:"User-Agent": "Meteor/1.0"
            params:
                user_id:'JAN-HUB'
                password:'j@NhU8'
                statevar:'run_report'
                username_display:'ID'
                api_reverse_lookup:'NO'
                id:'48302'
                page_length:'40000'
                record_start:'1'
                record_count:'40000'
        # return res.content
        xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
            if err then console.error('errors',err)
            else
                # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
                # console.dir json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1..5]
                # new_id = Docs.insert
            if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                for doc in json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                    # doc.type = 'customer'
                    existing_customer_doc =
                        Docs.findOne
                            type: 'customer'
                            "ev.CUST_NAME": doc.CUST_NAME
                    if existing_customer_doc
                        Docs.update existing_customer_doc._id,
                            $set:
                                ev: doc
                    unless existing_customer_doc
                        new_customer_doc = Docs.insert
                            type: 'customer'
                            ev: doc

    sync_ny_customers: () ->
        res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
            headers:"User-Agent": "Meteor/1.0"
            params:
                user_id:'JAN-HUB'
                password:'j@NhU8'
                statevar:'run_report'
                username_display:'ID'
                api_reverse_lookup:'NO'
                id:'49067'
                page_length:'10000'
                record_start:'1'
                record_count:'10000'
        # return res.content
        xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
            if err then console.error('errors',err)
            else
                # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
                # console.dir json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1..5]
                # new_id = Docs.insert
            if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                for doc in json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                    # doc.type = 'customer'
                    existing_customer_doc =
                        Docs.findOne
                            type: 'customer'
                            "ev.CUST_NAME": doc.CUST_NAME
                    if existing_customer_doc
                        # console.log 'existing', existing_customer_doc._id
                        Docs.update existing_customer_doc._id,
                            $set:
                                ev: doc
                    unless existing_customer_doc
                        # console.log 'new'
                        new_customer_doc = Docs.insert
                            type: 'customer'
                            ev: doc

    # sync_ny_statements: () ->
    #     res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
    #         headers:"User-Agent": "Meteor/1.0"
    #         params:
    #             user_id:'JAN-HUB'
    #             password:'j@NhU8'
    #             statevar:'run_report'
    #             username_display:'ID'
    #             api_reverse_lookup:'NO'
    #             id:'48927'
    #             page_length:'500'
    #             record_start:'1'
    #             record_count:'500'
    #     # return res.content
    #     xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
    #         if err then console.error('errors',err)
    #         else
    #             # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
    #             # console.dir json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1..5]
    #             # new_id = Docs.insert
    #         if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
    #             for doc in json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
    #                 # doc.type = 'statment'
    #                 existing_statment_doc =
    #                     Docs.findOne
    #                         type: 'statment'
    #                         "ev.CUST_NAME": doc.CUST_NAME
    #                 if existing_statment_doc
    #                     Docs.update existing_statment_doc._id,
    #                         $set:
    #                             ev: doc
    #                 unless existing_statment_doc
    #                     new_statment_doc = Docs.insert
    #                         type: 'statment'
    #                         ev: doc


#     list_attachments: (id) ->
#         res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
#             headers:"User-Agent": "Meteor/1.0"
#             params:
#                 user_id:'JAN-HUB'
#                 password:'j@NhU8'
#                 statevar:'list_attachment'
#                 username_display:'ID'
#                 id:id
#         # return res.content
# #         xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
# #             if err then console.error('errors',err)
# #             else
# #                 # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
# #                 # console.dir json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1..5]
# #                 # new_id = Docs.insert
# #             if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
# #                 for doc in json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
# #                     # doc.type = 'statment'
# #                     existing_statment_doc =
# #                         Docs.findOne
# #                             type: 'statment'
# #                             "ev.CUST_NAME": doc.CUST_NAME
# #                     if existing_statment_doc
# #                         Docs.update existing_statment_doc._id,
# #                             $set:
# #                                 ev: doc
# #                     unless existing_statment_doc
# #                         new_statment_doc = Docs.insert
# #                             type: 'statment'
# #                             ev: doc



    get_recent_customers: () ->
        res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
            headers:"User-Agent": "Meteor/1.0"
            params:
                user_id:'JAN-HUB'
                password:'j@NhU8'
                statevar:'run_report'
                username_display:'ID'
                api_reverse_lookup:'NO'
                id:'49072'
                page_length:'10000'
                record_start:'1'
                record_count:'10000'
        # return res.content
        xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
            if err then console.error('errors',err)
            else
                # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
                # console.dir json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1..5]
                # new_id = Docs.insert
            if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                for doc in json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                    # doc.type = 'customer'
                    existing_customer_doc =
                        Docs.findOne
                            type: 'customer'
                            "ev.CUST_NAME": doc.CUST_NAME
                    if existing_customer_doc
                        # console.log 'existing',existing_customer_doc._id
                        Docs.update existing_customer_doc._id,
                            $set: ev: doc
                    unless existing_customer_doc
                        # console.log 'new customer'
                        new_customer_doc = Docs.insert
                            type: 'customer'
                            ev: doc