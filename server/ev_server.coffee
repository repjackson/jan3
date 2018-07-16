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
                else
                    console.log 'existing user doc:', found_user._id

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
        # console.log res.content
        # console.log 'doesnt include'
        if res.content.includes("denied")
            console.log 'no'
            throw new Meteor.Error('permission denied', "Permission denied to get user")
        else
            console.log 'doesnt include'
        split_res = res.content.split '\r\n'
        # console.log typeof split_res
        save_json = {}
        for key_value_string in split_res
            split_key_value = key_value_string.split '|'
            # console.log split_key_value
            save_json["#{split_key_value[0]}"] = split_key_value[1]
        # console.log save_json
        Meteor.users.update user_doc._id,
            $set: ev: save_json
        # console.log 'updated', user_doc.username 

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

        # console.log res
        xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
            if err then console.error('errors',err)
            else
                # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
                # console.dir json_result.HISTORY.PROBLEM_RECORD
                # new_id = Docs.insert 
                # console.log 'new id', new_id
            if json_result.HISTORY.PROBLEM_RECORD
                for doc in json_result.HISTORY.PROBLEM_RECORD
                    # console.log doc
                    existing_history_doc = 
                        Docs.findOne 
                            type: 'history'
                            "ev.TIMESTAMP": doc.TIMESTAMP
                    if existing_history_doc
                        console.log "existing history #{existing_history_doc.ev.TIMESTAMP}"
                        # Docs.update existing_history_doc._id,
                        #     $set: ev: doc
                    else
                        Docs.insert
                            type:'history'
                            ev: doc
        
        
        # split_res = res.content.split '\r\n'
        # console.log typeof split_res
        # for area_string in split_res
        #     split_report = area_string.split '|'
        #     console.log split_report
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
        # console.log res
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
                page_length: 100
                record_start: 1
                record_count: 100
                username_display: 'ID'
                timestamp: "'2018-06-05'-'2018-07-20'"
        # console.log res
        xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
            if err then console.error('errors',err)
            else
                result = json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                # console.dir result
                for doc in json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                    # console.log doc
                    # doc.type = 'customer'
                    existing_search_history_doc = 
                        Docs.findOne 
                            type: 'search_history_doc'
                            "ev.ID": doc.ID
                    if existing_search_history_doc
                        console.log "existing search history doc #{existing_search_history_doc.ev.ID}"
                        # console.log doc
                        # Docs.update existing_search_history_doc._id,
                        #     $set: ev: doc
                    else                    
                        new_search_history_doc = Docs.insert 
                            type:'search_history_doc'
                            ev: doc
                        console.log "added #{doc.ID}"
    
    get_all_franchisees: () ->
        console.log 'starting franchisee sync'
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
                record_start:'10000'
                record_count:'10000'
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
                    existing_franchisee = 
                        Docs.findOne 
                            type: 'franchisee'
                            "ev.ID": doc.ID
                    if existing_franchisee
                        console.log "existing franchisee #{existing_franchisee.ev}"
                        # console.log doc
                        Docs.update existing_franchisee._id,
                            $set:
                                ev: doc
                    else                    
                        new_franchisee_doc = Docs.insert 
                            type:'franchisee'
                            ev: doc
                        console.log "added #{doc.SHORT_NAME}"
    
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
                page_length:'20000'
                record_start:'50000'
                record_count:'1'
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
                            "ev.ID": doc.ID
                            "ev.CUST_NAME": doc.CUST_NAME
                    # if existing_customer_doc
                    #     console.log "existing customer #{existing_customer_doc.ev.CUST_NAME}"
                        # Docs.update existing_customer_doc._id,
                        #     $set:
                        #         ev: doc
                    unless existing_customer_doc                    
                        new_customer_doc = Docs.insert 
                            type: 'customer'
                            ev: doc
                        console.log "added #{doc.CUST_NAME}"