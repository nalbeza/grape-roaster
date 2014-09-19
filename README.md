grape-roaster
=============

Build great APIs with Grape and Roaster

Exposed routes:

  POST   /albums(.:format)
  GET    /albums(.:format)
  GET    /albums/:resource_id(.:format)
  PUT    /albums/:resource_id(.:format)
  DELETE /albums/:resource_id(.:format)
  GET    /albums/:resource_id/links/tracks(.:format)
  POST   /albums/:resource_id/links/tracks(.:format)
  DELETE /albums/:resource_id/links/tracks(.:format)
  POST   /albums/:resource_id/links/tracks/:rel_ids(.:format)
  DELETE /albums/:resource_id/links/tracks/:rel_ids(.:format)
