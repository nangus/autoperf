#!/usr/bin/env phantomjs

Array.prototype.copyArgs = function copyArgs() {
    var n = new Array();
    this.forEach(function(e) {
        n.push(e);
    });
    n.shift(); // remove file name
    return n;
};
// usage:
//
// var arg = system.args.copy(); // see above
// var useFULL = arg.getArgs(['--full', '-f'], false); // false
// var useJSON = arg.getArgs(['--json', '-j'], false); // true
// var gotNAME = arg.getArgs(['--name', '-n'], true);  // foo
Array.prototype.getArg = function getArg(flags, hasValue) {
    for (var i = 0; i < flags.length; i++) {
        var pos = this.indexOf(flags[i]);
        if (pos !== -1) {
            if (hasValue) {
                try {
                    var ret = this[pos+1];
                    this.splice(pos,2);
                    return ret;
                } catch (e) {
                    console.trace(e);
                    return false;
                }
            }
            var len = this.length-1;
            this.splice(pos, 1); 
            return true;
        }
    }   
    return false;
};


var webpage = require('webpage'),
    system  = require('system'),
    fs      = require('fs'),
    args    = system.args.copyArgs();

function trim(str) {
     return str.replace(/^\s+/,'').replace(/\s+$/,'');
}


function usage() {
    console.log('Usage: % <URL(s)>|<URL(s) file> --file outputFile [--runs #]'+
    '\n\t--file  - destination file for the httperf wsesslog file'+
    '\n\t--runs  - number of extra runs to preform');
    phantom.exit();
}
function parsePaths(str) {
    var result = [];
    if (!str) {
        return result;
    }

    if (fs.exists(str)) {
        fs.read(str)
            .split('\n')
            .forEach(function(line) {
                if (line !== '') {
                    result.push(line);
                }
            });
    } else {
        str.split(',').forEach(function(item) {
            result.push(trim(item));
        });
    }
    return result;
}

if( phantom.version.major <=1 && phantom.version.minor<10){
    console.log('generate session log requires a minium phantomjs version of 1.10');
    usage();
}

if (system.args.length < 2) {
    usage();
}

var runns           = args.getArg(['-r','--runs'] , true) || 1;
var fileOutput      = args.getArg(['-f','--file'] , true) || '';
var limit           = 1;
var addresses       = parsePaths(args.shift());
var running         = 1;
var failures        = 0;

if( fileOutput === ''){
    usage();
}
//blank file before start
//fs.write(fileOutput,'','w');

//a simple way to extend the number of times that we want to run
for(var i =0 ; i<runns-1;i++){
    addresses.push(addresses[i]);
}

function launcher(runs) {
    if(failures>5){
        phantom.exit(1);
    }
    if(runs) running--;
    while(running < limit && addresses.length > 0){
        running++;
        collectData(addresses.shift());
    }
    if(running < 1 && addresses.length < 1 ){
        phantom.exit();
    }
};

function collectData(address){
    var session = '';
    var page    = require('webpage').create();
    var domain  = address.match("(^https?\:\/\/[^\/?#]+)(?:[\/?#]|$)")[1];
    var tim     = Date.now();
    var dupes   =[];
    page.settings.resourceTimeout = 10000;
    phantom.clearCookies();
    console.log('generating list for '+address);

    //debating dropping these lines they are only really needed when we are aborting requests
    page.onResourceError = function(resourceError) { };
    page.onError=function(error){ };

    //we do not care about the responce
    page.onResourceReceived = function(res){};

    page.onResourceRequested = function(requestData, request) {
        if(requestData.url.indexOf(domain)==0 && !dupes[requestData.url]){
            dupes[requestData.url]=1;
            var imageMatch=requestData.url.match(/(jpeg$|jpg$|gif$|png$|proxy)/);
            if(!imageMatch){
                var sesstring='';
                if(requestData.id !== 1){
                    sesstring='\t';
                }
                sesstring+=requestData.url.substring(domain.length);
                if(requestData.method === "POST"){
                    //httperf was choaking on requests that were too big
                    var data=requestData.postData;
                    if( data.length > 1000){
                        data=data.substring(0,1000);
                        data=data.substring(0,data.lastIndexOf('&'));
                    }
                    //this requires version 1.10 of phantomjs
                    sesstring+=' method=POST contents="'+data+'"';
                }
                if(requestData.id !== 1){
                    sesstring+=' think='+((Date.now()-tim)/1000);
                }
                session+=sesstring+'\n';
            }
        }
    };

    page.open(address, function(status) {
        if (status === 'success') {
            fs.write(fileOutput,session+'\n','a');
        } else {
            console.log('Unable to load the address!');
            failures++;
            addresses.push(address);
        }
        (page.close||page.release)();
        launcher(true);
    });
};
//Here we go!
launcher(true);

