# Fave Web Widget
## API
### Endpoint
GET http://app.readflyer.com/f

### Query Parameters

| Parameter | Required | Data Type | Example                    | Description          |
|-----------|:--------:|-----------|----------------------------|----------------------|
| url       | *        | String    | http://example.com/xyz     | Web URL of article   |
| title     |          | String    | Something Crazy Going On   | Headline of article  |
| image_url |          | String    | http://example.com/pic.jpg | Image URL of article |

#### Example

http://app.readflyer.com/f?url=http://example.com/xyz&title=Something%20Crazy%20Going%20On&image_url=http://example.com/pic.jpg


## Testing
### Web Preview Endpoint
GET http://app.readflyer.com/f/preview

#### Example
<http://app.readflyer.com/f/preview?url=https://en.wikipedia.org/wiki/2015_United_Nations_Climate_Change_Conference&title=At%20COP%2021,%20parties%20to%20the%20UNFCCC%20adopt%20an%20agreement%20aimed%20at%20limiting%20the%20rise%20in%20global%20temperatures&image_url=https://upload.wikimedia.org/wikipedia/commons/8/85/JCH_6442_%2822802505643%29.jpg>