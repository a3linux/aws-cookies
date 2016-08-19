console.log('[Amazon CloudWatch Notification]');

/*
 configuration for each condition.
 add any conditions here
*/
var ALARM_CONFIG = [{
  condition: /^OK/i,
  channel: " ", // override channel
  mention: " ", // mention someone
  color: "good",
  severity: "OK"
}, {
  condition: /^ALARM/i,
  channel: " ", // override channel
  mention: "<@channel>", // mention someone
  color: "danger",
  severity: "CRITICAL"
}];

var SLACK_CONFIG = {
  path: "/services/<YOUR_SLACK_CHANNEL_INCOMING_WEBHOOK_TOKEN>"
};

var http = require('https');
var querystring = require('querystring');
exports.handler = function(event, context) {
  console.log(event.Records[0]);

  // parse information
  var message = event.Records[0].Sns.Message;
  var subject = event.Records[0].Sns.Subject;
  var timestamp = event.Records[0].Sns.Timestamp;

  // vars for final message
  var channel;
  var severity;
  var color;

  // create post message
  var alarmMessage = " *[Amazon CloudWatch Notification]* \n" +
    "*Subject*: " + subject + "\n" +
    "*Message*: " + message + "\n" +
    "*Timestamp*: " + timestamp;

  // check subject for condition
  var i = 0;
  for (i = 0; i < ALARM_CONFIG.length; i++) {
    var row = ALARM_CONFIG[i];
    console.log(row);
    if (subject.match(row.condition) !== null) {
      console.log("Matched condition: " + row.condition);

      alarmMessage = row.mention + " " + alarmMessage + " ";
      channel = row.channel;
      severity = row.severity;
      color = row.color;
      break;
    }
  }

  if (!channel) {
    console.log("Could not find condition. We will publish as unknown!");
    channel = " ";
    severity = "UNKNOWN";
    color = "warning";
  }

  var payloadStr = JSON.stringify({
    "attachments": [{
      "fallback": alarmMessage,
      "text": alarmMessage,
      "mrkdwn_in": ["text"],
      "username": "AWS-CloudWatch-ALARM",
      "fields": [{
        "title": "Severity",
        "value": severity,
        "short": true
      }],
      "color": color
    }]
  });
  var postData = querystring.stringify({
    "payload": payloadStr
  });
  console.log(postData);
  var options = {
    hostname: "hooks.slack.com",
    port: 443,
    path: SLACK_CONFIG.path,
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Content-Length': postData.length
    }
  };

  var req = http.request(options, function(res) {
    console.log("Got response: " + res.statusCode);
    res.on("data", function(chunk) {
      console.log('BODY: ' + chunk);
      context.done(null, 'done!');
    });
  }).on('error', function(e) {
    context.done('error', e);
  });
  req.write(postData);
  req.end();
};
