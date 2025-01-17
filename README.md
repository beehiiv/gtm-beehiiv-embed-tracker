# GTM Attribution Tracking Template

A Google Tag Manager custom template for comprehensive attribution tracking, including UTM parameters, click IDs, and referrer analysis.

## Features

- Tracks UTM parameters (source, medium, campaign, term, content)
- Automatically detects and tracks ad platform click IDs:
  - Google (gclid, gclsrc, dclid, wbraid, gbraid, gad_source)
  - Facebook (fbclid)
  - LinkedIn (li_fat_id)
  - TikTok (ttclid)
  - Twitter (twclid)
  - Bing (msclkid)
- Analyzes referrer information for organic and social traffic sources
- Stores attribution data in a first-party cookie
- Pushes attribution data to the dataLayer for easy integration with other tags
- Debug mode for troubleshooting
- Configurable cookie expiration

## Installation

1. Open Google Tag Manager
2. Navigate to Templates
3. Click "New" in the Tag Templates section
4. Click "Import" from the Gallery
5. Search for "Attribution Tracking Template"
6. Click "Add to Workspace"

## Configuration

### Required Fields
- **Cookie Expiry**: Number of days before the attribution cookie expires (default: 30)
- **Debug Mode**: Enable console logging for troubleshooting (default: false)
- **Child Origin**: Origin URL for embedded content (default: https://embeds.beehiiv.com)

### Implementation

1. Create a new tag using the template
2. Set your desired configuration options
3. Set the trigger to fire on page view or your preferred event
4. Test using GTM's preview mode
5. Publish your container

## Data Format

The template pushes attribution data to the dataLayer in the following format:

```javascript
{
  event: 'attribution_data',
  attribution: {
    source: string,
    medium: string,
    campaign: string,
    term: string,
    content: string,
    last_updated: timestamp,
    referrer: string,
    landing_page: string
  }
}
```

## Contributing

1. Fork the repository
2. Create a new branch for your feature
3. Submit a pull request with a clear description of your changes

## License

MIT License - See LICENSE file for details

## Support

For issues and feature requests, please use the GitHub issues tracker.
