json.set! :errors do
  json.set! :message, 'Unregistered user'
end
json.user(@user, :full_name, :profile_picture_url)
