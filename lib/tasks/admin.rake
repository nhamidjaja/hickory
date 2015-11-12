namespace :admin  do
  task create: :environment do
    print 'email: '
    email = $stdin.gets.chomp.strip.to_s

    print 'password: '
    password = $stdin.gets.chomp.strip.to_s

    admin = Admin.create!(email: email, password: password)

    print "Success! Created admin #{admin.email}.\n"
  end
end
