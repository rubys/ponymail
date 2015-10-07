# Pony Mail
<img src="https://github.com/Humbedooh/ponymail/blob/master/site/images/logo_large.png" align="left"/><br/><br/>
Pony Mail is a web-based mail archive browser
licensed under the Apache License v/2.0 and built to scale 
to millions of archived messages with hundreds of requests 
per second.

Pony Mail allows you to browse and interact with mailing lists 
using Mozilla Persona or OAuth2 for authentication.

![Ponies](https://github.com/Humbedooh/ponymail/blob/master/site/images/demo.png)

See [http://ponymail.info](http://ponymail.info) for a demo.

Pony Mail works in both public, private and mixed-mode, allowing you 
to have one unified place for all your communication, both public and 
private.

### Features include: ###
* Public and private list viewing based on auth
* Cross-list threading
* OpenSearch support for browsers (can add as search engine)
* In-browser reply to mailing lists
* Fast and intuitive searching
* Threaded and flat view modes
* Notifications of replies to emails sent via Pony Mail
* Email and list statistics
* Multi-site, Multi-list handling
* Word clouds (yay!)
* Fuzzy-logic email grouping/threading (based in part on JWZ's ideas)
* Supports both custom OAuth and Mozilla Persona
* Atom feeds for all lists (including private ones!)

### Requirements: ###

* ElasticSearch backend
* Apache HTTP Server frontend with mod_lua loaded OR
  * Nginx with nginx-extras (ng-lua module) AND lua-apr installed
* Python 3.x for importing (with elasticsearch and formatflowed via pip)
* MailMan3 if you fancy that (we have a python3 archive plugin)
* OR any mailing list system of your choice (use archiver plugin with stdin)
* Lua 5.1 or 5.2 + lua-cjson, luasec and luasocket


### Getting started ###
(Optionally see the [detailed installation instructions](docs/INSTALLING.md) for more information)

1. Install Apache httpd + mod_lua and the lua libs (see http://modlua.org/gs/installing if need be)
2. Install ElasticSearch
3. go to tools/ and run python setup.py - follow the instructions and enter info
4. Fiddle a bit with site/js/config.js for now
5. import mbox data with import-mbox.py if need be
6. All done :)


### TODO: ###
* ~~Set up dir structure~~ (*DONE*)
* ~~Import site data~~ (*DONE*)
* ~~Import tools~~ (*DONE*)
* ~~Import settings / setup tools~~ (*DONE*)
* ~~Import, fix archiver~~ (*DONE*)
* ~~Add license headers (ALv2) to everything~~ (*DONE(?)*)
* ~~Have reply feature actually work~~ (*DONE*)
* ~~Split JS into smaller files for development, bundle together for releases~~ (*DONE*)
* Start on documentation
* Rework JS, turn those ugly innerHTML hacks into proper DOM handling
* Set up notification system (depends on reply system) (Sort of works, but still *WIP!*)
* Have it work with ES with auth mode or via HTTPS

