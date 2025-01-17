___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "beehiiv Embed Tracker",
  "categories": ["ANALYTICS", "ATTRIBUTION", "MARKETING"],
  "brand": {
    "id": "github_com_beehiiv",
    "displayName": "beehiiv",
    "thumbnail": "https://media.beehiiv.com/cdn-cgi/image/fit=scale-down,format=auto,onerror=redirect,quality=80/uploads/publication/logo/a8e88f38-1bf6-4bad-8154-2c897fe51252/thumb_Social_Profile_pic.png"
  },
  "description": "Track and analyze marketing attribution data including UTM parameters, ad platform click IDs (Google, Facebook, LinkedIn, TikTok, Twitter, Bing), and referrer information for embeded beehiiv Subscriber Forms. Enables advanced attribution within beehiiv and with external tools.
  "containerContexts": [
    "WEB"
  ],
  "requirements": [
    "This template requires access to set first-party cookies for storing attribution data.",
    "The dataLayer must be initialized before this template runs."
  ],
  "documentation": "https://github.com/YOUR_REPO/gtm-attribution-template",
  "releaseNotes": [
    {
      "version": "1.0.0",
      "description": "Initial release with support for:\n- UTM parameter tracking\n- Ad platform click ID detection\n- Referrer analysis\n- First-party cookie storage\n- DataLayer integration\n- Debug mode"
    }
  ]
}


___TEMPLATE_PARAMETERS___

[]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const createArgumentsQueue = require('createArgumentsQueue');
const setCookie = require('setCookie');
const getCookieValues = require('getCookieValues');
const getUrl = require('getUrl');
const getReferrerUrl = require('getReferrerUrl');
const queryPermission = require('queryPermission');
const logToConsole = require('logToConsole');
const JSON = require('JSON');
const Object = require('Object');
const getTimestampMillis = require('getTimestampMillis');
const encodeUriComponent = require('encodeUriComponent');
const makeTableMap = require('makeTableMap');
const createQueue = require('createQueue');
const dataLayerPush = createQueue('dataLayer');

// Configuration object
const config = {
  cookieName: 'attribution_data',
  cookieExpiry: data.cookieExpiry || 30,
  debugMode: data.debugMode || false,
  childOrigin: data.childOrigin || 'https://embeds.beehiiv.com'
};

// Parse URL parameters
function parseParameters() {
  const parsed = {};
  const currentUrl = getUrl();
  
  // Parse UTM parameters
  const utmParams = ['source', 'medium', 'campaign', 'term', 'content'];
  utmParams.forEach(function(param) {
    const value = getUrl('utm_' + param);
    if (value) parsed[param] = value;
  });
  
  // Handle click IDs
  if (!parsed.source && !parsed.medium) {
    const clickIds = {
      google: ['gclid', 'gclsrc', 'dclid', 'wbraid', 'gbraid', 'gad_source'],
      facebook: ['fbclid'],
      bing: ['msclkid'],
      linkedin: ['li_fat_id'],
      tiktok: ['ttclid'],
      twitter: ['twclid']
    };
    
    Object.keys(clickIds).forEach(function(source) {
      const ids = clickIds[source];
      for (let i = 0; i < ids.length; i++) {
        if (getUrl(ids[i])) {
          parsed.source = source;
          parsed.medium = 'cpc';
          break;
        }
      }
    });
  }
  
  return parsed;
}

// Parse referrer information
function parseReferrer() {
  const referrer = getReferrerUrl();
  if (!referrer) return {};
  
  const parsed = {
    source: referrer,
    medium: 'referral'
  };
  
  const rules = makeTableMap([
    ['google', 'organic', 'google'],
    ['bing.com', 'organic', 'bing'],
    ['duckduckgo.com', 'organic', 'duckduckgo'],
    ['yahoo.com', 'organic', 'yahoo'],
    ['ecosia.org', 'organic', 'ecosia'],
    ['ask.com', 'organic', 'ask'],
    ['aol.com', 'organic', 'aol'],
    ['baidu.com', 'organic', 'baidu'],
    ['yandex', 'organic', 'yandex'],
    ['linkedin.com', 'social', 'linkedin'],
    ['facebook.com', 'social', 'facebook'],
    ['t.co', 'social', 'twitter'],
    ['instagram.com', 'social', 'instagram'],
    ['pinterest.com', 'social', 'pinterest'],
    ['youtube.com', 'social', 'youtube']
  ]);
  
  Object.keys(rules).forEach(function(domain) {
    if (referrer.indexOf(domain) !== -1) {
      const rule = rules[domain];
      parsed.source = rule[2];
      parsed.medium = rule[1];
    }
  });
  
  return parsed;
}

// Get cookie data
function getCookieData() {
  const cookieValues = getCookieValues('attribution_data');
  if (!cookieValues || !cookieValues[0]) return null;
  
  const parsedData = JSON.parse(cookieValues[0]);
  return parsedData || null;
}

// Set cookie data
function setCookieData(data) {
  if (queryPermission('set_cookies', 'attribution_data')) {
    setCookie('attribution_data', JSON.stringify(data), {
      domain: 'auto',
      path: '/',
      maxAge: config.cookieExpiry * 24 * 60 * 60,
      secure: true
    });
  }
}

// Get attribution data
function getAttributionData() {
  const params = parseParameters();
  const referrerData = Object.keys(params).length === 0 ? parseReferrer() : {};
  const existingData = getCookieData() || {};
  
  if (Object.keys(params).length === 0 && Object.keys(referrerData).length === 0) {
    return existingData;
  }
  
  const timestamp = getTimestampMillis();
  const attributionData = {
    last_updated: timestamp,
    referrer: getReferrerUrl(),
    landing_page: getUrl()
  };
  
  Object.keys(referrerData).forEach(function(key) {
    attributionData[key] = referrerData[key];
  });
  
  Object.keys(params).forEach(function(key) {
    attributionData[key] = params[key];
  });
  
  setCookieData(attributionData);
  return attributionData;
}

// Initialize tracking
function init() {
  if (config.debugMode) {
    logToConsole('Beehiiv Tracker Initializing...');
  }
  
  const attributionData = getAttributionData();
  
  // Push attribution data
  dataLayerPush({
  event: 'attribution_data',
  attribution: attributionData
});
  
  if (config.debugMode) {
    logToConsole('Attribution Data:', attributionData);
  }
}

// Run the tracker
init();

// Signal successful completion
data.gtmOnSuccess();


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_globals",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "dataLayer"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_referrer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urlParts",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "queriesAllowed",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "set_cookies",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_url",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urlParts",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "queriesAllowed",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 1/17/2025, 2:44:39 PM


