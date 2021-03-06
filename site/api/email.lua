--[[
 Licensed to the Apache Software Foundation (ASF) under one or more
 contributor license agreements.  See the NOTICE file distributed with
 this work for additional information regarding copyright ownership.
 The ASF licenses this file to You under the Apache License, Version 2.0
 (the "License"); you may not use this file except in compliance with
 the License.  You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
]]--

-- This is email.lua - a script for fetching a document (email)

local JSON = require 'cjson'
local elastic = require 'lib/elastic'
local aaa = require 'lib/aaa'
local user = require 'lib/user'
local cross = require 'lib/cross'
local config = require 'lib/config'

function handle(r)
    r.content_type = "application/json"
    local get = r:parseargs()
    local eid = (get.id or ""):gsub("\"", "")
    local doc = elastic.get("mbox", eid or "hmm")
    
    -- Try searching by original source mid if not found, for backward compat
    if not doc or not doc.subject then
        local docs = elastic.find("message-id:\"" .. r:escape(eid) .. "\"", 1, "mbox")
        if #docs == 1 then
            doc = docs[1]
        end
        
        -- shortened link maybe?
        if #docs == 0 and #eid == 18 then
            docs = elastic.find("mid:" .. r:escape(eid) .. "*", 1, "mbox")
        end
        if #docs == 1 then
            doc = docs[1]
        end
    end
    
    -- Did we find an email?
    if doc then
        local canAccess = false
        local account = user.get(r)
        
        -- Is this a private email? and if so, does the user have access to view it?
        if doc.private then
            if account then
                local lid = doc.list_raw:match("<[^.]+%.(.-)>")
                local flid = doc.list_raw:match("<([^.]+%..-)>")
                for k, v in pairs(aaa.rights(r, account)) do
                    if v == "*" or v == lid or v == flid then
                        canAccess = true
                        break
                    end
                end
            else
                r:puts(JSON.encode{
                    error = "You must be logged in to view this email"
                })
                return cross.OK
            end
        else
            canAccess = true
        end
        
        -- If we can access this email, ...
        if canAccess then
            doc.tid = doc.request_id
            
            -- Are we in fact looking for an attachment inside this email?
            if get.attachment then
                local hash = r:escape(get.file)
                local fdoc = elastic.get("attachment", hash)
                if fdoc and fdoc.source then
                    local out = r:base64_decode(fdoc.source:gsub("\n", "")) -- bug in mod_lua?
                    local ct = "application/binary"
                    local fn = "unknown"
                    local fs = 0
                    for k, v in pairs(doc.attachments or {}) do
                        if v.hash == hash then
                            ct = v.content_type or "application/binary"
                            fn = v.filename
                            fs = v.size
                            break
                        end
                    end
                    r.content_type = ct
                    r.headers_out['Content-Length'] = fs
                    if not (ct:match("image") or ct:match("text")) then
                        r.headers_out['Content-Disposition'] = ("attachment; filename=\"%s\";"):format(fn)
                    end
                    r:write(out)
                    return cross.OK
                end
            -- Or do we just want the email itself?
            else
                doc.from = doc.from or "unknown"
                local eml = doc.from:match("<(.-)>") or doc.from:match("%S+@%S+") or nil
                if eml == nil and doc.from:match(".- at .- %(") then
                    eml = doc.from:match("(.- at .-) %("):gsub(" at ", "@")
                    doc.from = eml
                elseif eml == nil then
                    eml = "unknown"
                end
                if not account then -- anonymize email address if not logged in
                    doc.from = doc.from:gsub("(%S+)@(%S+)", function(a,b) return a:sub(1,2) .. "..." .. "@" .. b end)
                    if doc.from_raw then
                        doc.from_raw = doc.from_raw:gsub("(%S+)@(%S+)", function(a,b) return a:sub(1,2) .. "..." .. "@" .. b end)
                    end
                end
                
                -- Anonymize any email address mentioned in the email if not logged in
                if not account and config.antispam then
                    doc.body = doc.body:gsub("<(%S+)@([-a-zA-Z0-9_.]+)>", function(a,b) return "<" .. a:sub(1,2) .. "..." .. "@" .. b .. ">" end)
                end
                
                
                -- Anonymize to/cc if full_headers is false
                if not config.full_headers then
                    doc.to = nil
                    doc.cc = nil
                end      
                doc.gravatar = r:md5(eml:lower())
                r:puts(JSON.encode(doc))
            end
        else
            r:puts(JSON.encode{
                    error = "You do not have access to view this email, sorry."
                })
            return cross.OK
        end
    else
        r:puts[[{}]]
    end
    return cross.OK
end

cross.start(handle)