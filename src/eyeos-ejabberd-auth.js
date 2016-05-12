#!/usr/bin/env node
/*
    Copyright (c) 2016 eyeOS

    This file is part of Open365.

    Open365 is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

require('./lib/pipe');
var settings = require("./settings");
var EyeosAuth = require('eyeos-auth');
var eyeosAuth = new EyeosAuth();
process.stdin.resume();

var currentData = new Buffer([]);
process.stdin.on('data', function(chunk) {
    currentData = Buffer.concat([currentData, chunk]);
    if(currentData.length > 1) {
        //first, we need to know the len
        var len = currentData.readUInt16BE(0);

        if(currentData.length-2 >= len) {
            var data = currentData.toString('utf-8', 2);

            var parts = data.split(':');
            switch(parts[0]) {
                case 'auth':

                    var user = parts[1].split("#")[0];
                    var domain = parts[1].split("#")[1];
                    var password = parts.slice(3).join(":");

                    try {
                        var authinfo = JSON.parse(password);
                        var card = JSON.parse(authinfo.card);

                        var isValid = eyeosAuth.verifyRequest({headers:authinfo});
                        if(isValid && card.username === user && card.domain === domain) {
                            ok();
                        } else {
                            fail();
                        }
                    } catch(e) {
                        fail();
                    }

                    break;
                default:
                    fail();
                    break;
            }
            currentData = new Buffer([]);
        }
    }
});

function fail() {
    process.stdout.write(new Buffer([0, 2, 0, 0]));
}

function ok() {
    process.stdout.write(new Buffer([0, 2, 0, 1]));
}
