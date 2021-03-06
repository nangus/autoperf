#!/usr/bin/env phantomjs

Array.prototype.copyArgs = function copyArgs() {
    var n = new Array();
    this.forEach(function(e) {
        n.push(e);
    });
    n.shift(); // remove file name
    return n;
};

var webpage = require('webpage'),
    system  = require('system'),
    args    = system.args.copyArgs();

function usage() {
    console.log('Usage: % <URL(s)>|<URL(s) file>');
    phantom.exit(1);
}


if (system.args.length < 2) {
    usage();
}

var addr        = args.shift();
var page        = require('webpage').create();
page.settings.resourceTimeout = 10000;
 
page.open(addr, function(status) {
    if (status === 'success') {
        var result=null;
        var result=page.evaluate( function(){
            return document.querySelector('a.business-name').getAttribute('href');
        });
        console.log(result);
        if(result.indexOf('TypeError') == 0){
            phantom.exit(2);
        }
    } else {
        console.log('Unable to load the address!');
        phantom.exit(3);
    }
    (page.close||page.release)();
    phantom.exit();
});

