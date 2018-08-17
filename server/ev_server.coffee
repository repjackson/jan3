Meteor.methods
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
        console.dir res.content
        split_res = res.content.split '\r\n'
        
        for user_string in split_res
            split_user = user_string.split '|'
            console.log split_user
            if split_user[0]
                found_user = 
                    Docs.findOne 
                        type:'user'
                        user_id:split_user[0]
                
                unless found_user
                    new_user_id = Docs.insert
                        type:'user'
                        user_id:split_user[0]
                        user_first_name:split_user[1]
                        user_last_name:split_user[2]
                    console.log 'added user doc id:', new_user_id
                # else
                #     console.log 'existing user doc:', found_user._id
                Meteor.call 'get_user_info', split_user[0]

    get_user_info: (username)->
        # users_cursor = Meteor.users.find({}).fetch()
        # for each_user in users_cursor

        user_doc = Meteor.users.findOne username:username
        # console.log each_user
        # if each_user.ev.LAST_NAME
        #     console.log 'skipping existing ev', each_user.username
        # else 
        res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
            headers: "User-Agent": "Meteor/1.0"
            params:
                user_id:'JAN-HUB'
                password:'j@NhU8'
                statevar:'get_user_info'
                login_id: username
                # console.log 'new id', new_id
        # console.log res
        if res.content.includes("denied")
            throw new Meteor.Error('permission denied', "Permission denied to get user")
        else
            split_res = res.content.split '\r\n'
            save_json = {}
            for key_value_string in split_res
                split_key_value = key_value_string.split '|'
                save_json["#{split_key_value[0]}"] = split_key_value[1]
            if user_doc
                Meteor.users.update user_doc._id,
                    $set: ev: save_json

    get_history: () ->
        res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
            headers: "User-Agent": "Meteor/1.0"
            params:
                user_id:'JAN-HUB'
                password:'j@NhU8'
                statevar:'history'
                cutoff:  moment().subtract(100, 'days').calendar()
                # cutoff_end:  moment(Date.now()+10000).format()
                # evhist_sellist=selectionList 
                # hist_range_end=timestamp 
                # hist_range_start=timestamp 
                # username_display=ID | LAST | FIRST 
                # dd_name_n=value 
                # show_attributes=YES | NO

        xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
            if err then console.error('errors',err)
            else
                # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
                # console.dir json_result.HISTORY.PROBLEM_RECORD
                # new_id = Docs.insert 
            if json_result.HISTORY.PROBLEM_RECORD
                for doc in json_result.HISTORY.PROBLEM_RECORD
                    existing_history_doc = 
                        Docs.findOne 
                            type: 'history'
                            "ev.TIMESTAMP": doc.TIMESTAMP
                    if existing_history_doc
                        # Docs.update existing_history_doc._id,
                        #     $set: ev: doc
                    else
                        Docs.insert
                            type:'history'
                            ev: doc
        
        
        # split_res = res.content.split '\r\n'
        # for area_string in split_res
        #     split_report = area_string.split '|'
            # Docs.insert
            #     type:'meta'
            #     area: split_report[0]
            #     jpid: split_report[1]
            #     value: split_report[2]

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
                    # console.dir updatedList
                    existing_jpid = 
                        Docs.findOne 
                            type: 'jpid'
                            jpid: jp_id
                    if existing_jpid
                        Docs.update existing_jpid,
                            $set:
                                ev: json_result.PROBLEM_RECORD
                    else                    
                        new_jpid = Docs.insert 
                            type:'jpid'
                            jpid:jp_id
                            ev: json_result.PROBLEM_RECORD
                            
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
                        console.log "existing special_service #{existing_service_doc.ev.FRANCHISEE}"
                        # console.log doc
                        Docs.update existing_service_doc._id,
                            $set:
                                ev: doc
                    else                    
                        new_special_service_doc = Docs.insert 
                            type:'special_service'
                            jpid: doc.ID
                            ev: doc
                        console.log "added #{doc.ID}"
    
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
                page_length:'100'
                record_start:'1'
                record_count:'100'
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
                    console.log doc
                    # existing_service_doc = 
                    #     Docs.findOne 
                    #         type: 'special_service'
                    #         jpid: doc.ID
                    # if existing_service_doc
                    #     console.log "existing special_service #{existing_service_doc.ev.FRANCHISEE}"
                    #     # console.log doc
                    #     Docs.update existing_service_doc._id,
                    #         $set:
                    #             ev: doc
                    # else                    
                    #     new_special_service_doc = Docs.insert 
                    #         type:'special_service'
                    #         jpid: doc.ID
                    #         ev: doc
                    #     console.log "added #{doc.ID}"
    
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
        # console.log res.content
        xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
            if err then console.error('errors',err)
            else
        #         # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
        #         # console.dir json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1..5]
        #         # new_id = Docs.insert 
        #         # console.log 'new id', new_id
            if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                for doc in json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                    console.log doc
                    # doc.type = 'customer'
                    existing_office_doc = 
                        Docs.findOne 
                            type: 'office'
                            "ev.ID": doc.ID
                    if existing_office_doc
                        console.log "existing office #{existing_office_doc.ev.MASTER_LICENSEE}"
                        # console.log doc
                        Docs.update existing_office_doc._id,
                            $set: ev: doc
                    else                    
                        new_office_doc = Docs.insert 
                            type:'office'
                            ev: doc
                        console.log "added #{doc.ID}"
    
    sync_customers: () ->
        console.log 'starting customer sync'
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
        # console.log res.content
        xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
            if err then console.error('errors',err)
            else
                # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
                # console.dir json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1..5]
                # new_id = Docs.insert 
                # console.log 'new id', new_id
            if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                for doc in json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                    console.log doc
                    # doc.type = 'customer'
                    existing_customer_doc = 
                        Docs.findOne 
                            type: 'customer'
                            "ev.CUST_NAME": doc.CUST_NAME
                    if existing_customer_doc
                        console.log "existing customer #{existing_customer_doc.ev.CUST_NAME}"
                        Docs.update existing_customer_doc._id,
                            $set:
                                ev: doc
                    unless existing_customer_doc                    
                        new_customer_doc = Docs.insert 
                            type: 'customer'
                            ev: doc
                        console.log "added #{doc.CUST_NAME}"
                        
    sync_ny_customers: () ->
        console.log 'starting ny customer sync'
        res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
            headers:"User-Agent": "Meteor/1.0"
            params:
                user_id:'JAN-HUB'
                password:'j@NhU8'
                statevar:'run_report'
                username_display:'ID'
                api_reverse_lookup:'NO'
                id:'49067'
                page_length:'1000'
                record_start:'1'
                record_count:'1000'
        # return res.content
        # console.log res.content
        xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
            if err then console.error('errors',err)
            else
                # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
                # console.dir json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1..5]
                # new_id = Docs.insert 
                # console.log 'new id', new_id
            if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                for doc in json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                    # console.log doc
                    # doc.type = 'customer'
                    existing_customer_doc = 
                        Docs.findOne 
                            type: 'customer'
                            "ev.CUST_NAME": doc.CUST_NAME
                    if existing_customer_doc
                        console.log "existing customer #{existing_customer_doc.ev.CUST_NAME}"
                        Docs.update existing_customer_doc._id,
                            $set:
                                ev: doc
                    unless existing_customer_doc                    
                        new_customer_doc = Docs.insert 
                            type: 'customer'
                            ev: doc
                        console.log "added #{doc.CUST_NAME}: #{doc.MASTER_LICENSEE}"
                        
    # sync_ny_statements: () ->
    #     console.log 'starting ny statement sync'
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
    #     # console.log res.content
    #     xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
    #         if err then console.error('errors',err)
    #         else
    #             # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
    #             # console.dir json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1..5]
    #             # new_id = Docs.insert 
    #             # console.log 'new id', new_id
    #         if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
    #             for doc in json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
    #                 console.log doc
    #                 # doc.type = 'statment'
    #                 existing_statment_doc = 
    #                     Docs.findOne 
    #                         type: 'statment'
    #                         "ev.CUST_NAME": doc.CUST_NAME
    #                 if existing_statment_doc
    #                     console.log "existing statment #{existing_statment_doc.ev.CUST_NAME}"
    #                     Docs.update existing_statment_doc._id,
    #                         $set:
    #                             ev: doc
    #                 unless existing_statment_doc                    
    #                     new_statment_doc = Docs.insert 
    #                         type: 'statment'
    #                         ev: doc
    #                     console.log "added #{doc.CUST_NAME}"
                        
                        
#     list_attachments: (id) ->
#         console.log 'starting ny statement sync'
#         res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
#             headers:"User-Agent": "Meteor/1.0"
#             params:
#                 user_id:'JAN-HUB'
#                 password:'j@NhU8'
#                 statevar:'list_attachment'
#                 username_display:'ID'
#                 id:id
#         # return res.content
#         console.log res.content
# #         xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
# #             if err then console.error('errors',err)
# #             else
# #                 # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
# #                 # console.dir json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1..5]
# #                 # new_id = Docs.insert 
# #                 # console.log 'new id', new_id
# #             if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
# #                 for doc in json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
# #                     console.log doc
# #                     # doc.type = 'statment'
# #                     existing_statment_doc = 
# #                         Docs.findOne 
# #                             type: 'statment'
# #                             "ev.CUST_NAME": doc.CUST_NAME
# #                     if existing_statment_doc
# #                         console.log "existing statment #{existing_statment_doc.ev.CUST_NAME}"
# #                         Docs.update existing_statment_doc._id,
# #                             $set:
# #                                 ev: doc
# #                     unless existing_statment_doc                    
# #                         new_statment_doc = Docs.insert 
# #                             type: 'statment'
# #                             ev: doc
# #                         console.log "added #{doc.CUST_NAME}"



    get_recent_customers: () ->
        console.log 'starting recent customers update'
        res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
            headers:"User-Agent": "Meteor/1.0"
            params:
                user_id:'JAN-HUB'
                password:'j@NhU8'
                statevar:'run_report'
                username_display:'ID'
                api_reverse_lookup:'NO'
                id:'49072'
                page_length:'1000'
                record_start:'1'
                record_count:'1000'
        # return res.content
        # console.log res.content
        xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
            if err then console.error('errors',err)
            else
                # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
                # console.dir json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1..5]
                # new_id = Docs.insert 
                # console.log 'new id', new_id
            if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                for doc in json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                    # console.log doc
                    # doc.type = 'customer'
                    existing_customer_doc = 
                        Docs.findOne 
                            type: 'customer'
                            "ev.CUST_NAME": doc.CUST_NAME
                    if existing_customer_doc
                        console.log "existing customer #{existing_customer_doc.ev.CUST_NAME}"
                        Docs.update existing_customer_doc._id,
                            $set:
                                ev: doc
                    unless existing_customer_doc                    
                        new_customer_doc = Docs.insert 
                            type: 'customer'
                            ev: doc
                        console.log "added #{doc.CUST_NAME}: #{doc.MASTER_LICENSEE}"
                        
