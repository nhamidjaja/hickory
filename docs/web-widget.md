# Fave Web Widget
## Introduction
A fave web widget allows a user to easily share articles they find interesting to their followers. With one click, all of the user's followers will be able to read the same articles that the original user is reading. Theoretically the better your content, the more viral it becomes.

## How?
Placing a fave widget on your site is as easy as placing a hyperlink using an `<a>` tag. The `href` attribute will need to be inserted programmatically along with the endpoint and the following query parameters:

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

### Button Styling
We do not have a strict styling requirement. We prefer for you to prepare a design that suits your web page's overall UI, but we do ask you to include our logo and the text **Fave** in the button. If you require graphical assets such as logos for a customized design, feel free to contact us and we will provide it for you.

If you wish to use our default styling it is available below. However, at the moment, we ask that you host the logo on your web server for better performance.

<div style="width: 90px; margin: 0 0 15px 0;">
<style>
.btn-fave {
  -webkit-border-radius: 3; -moz-border-radius: 3; border-radius: 3px; font-family: Helvetica Neue; color: #ffffff; font-size: 11px; font-weight: bold; background: #f59930; padding: 3px 10px 0px 10px; text-decoration: none;
}
.btn-fave:hover {
  background: #ea8a20; text-decoration: none;
}
.btn-fave img{
  padding-right: 3px; height: 18px;
}
.btn-fave span{
  font-size: 18px;
}
</style>
  <a href="http://app.readflyer.com">
    <div class="btn-fave"><img src="./flyer-base-flat-01.svg" />
      <span>
        Fave
      </span>
    </div>
  </a>
</div>

```
  <style>
  .btn-fave {
    -webkit-border-radius: 3; -moz-border-radius: 3; border-radius: 3px; font-family: Helvetica Neue; color: #ffffff; font-size: 11px; font-weight: bold; background: #f59930; padding: 3px 10px 0px 10px; text-decoration: none;
  }
  .btn-fave:hover {
    background: #ea8a20; text-decoration: none;
  }
  .btn-fave img{
    padding-right: 3px; height: 18px;
  }
  .btn-fave span{
    font-size: 18px;
  }
  </style>
  
  <div style="width: 90px; margin: 0 0 15px 0;">
    <a href="http://app.readflyer.com">
      <div class="btn-fave"><img src="./flyer-base-flat-01.svg" />
        <span>
          Fave
        </span>
      </div>
    </a>
  </div>
```

## Testing
You can test out what a fave will look like by going to the following URL using your web browser:
### Web Preview Endpoint
GET http://app.readflyer.com/f/preview

#### Example
<http://app.readflyer.com/f/preview?url=https://en.wikipedia.org/wiki/2015_United_Nations_Climate_Change_Conference&title=At%20COP%2021,%20parties%20to%20the%20UNFCCC%20adopt%20an%20agreement%20aimed%20at%20limiting%20the%20rise%20in%20global%20temperatures&image_url=https://upload.wikimedia.org/wikipedia/commons/8/85/JCH_6442_%2822802505643%29.jpg>