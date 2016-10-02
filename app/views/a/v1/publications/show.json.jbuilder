json.publication do
  json.partial! 'feeder', publication: @publication
  json.is_subscribing @is_subscribing
end 