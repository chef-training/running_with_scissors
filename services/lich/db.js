var nconf = require('nconf');

console.log("Loading Configuration");

const nconf_file = process.env.APP_CONFIG || './default-config.json';
nconf.file({ file: nconf_file });

console.log("Creating Database Connection String");

var dbConnectionString = nconf.get('sqlite')['path'];

console.log("Connection String: " + dbConnectionString);

console.log("Connecting to Database");

var sqlite3 = require('sqlite3').verbose();
var db = new sqlite3.Database(dbConnectionString);

console.log(db);
module.exports =  db;
