namespace :friends  do
  task seed: :environment do
    print 'Create friends for username: '
    username = $stdin.gets.chomp.strip.to_s

    user = User.find_by_username(username)
    unless user
      fail("No User with username: #{username}")
    end

    print 'How many friends? (positive integer only) '
    amount = $stdin.gets.chomp.strip.to_i

    amount.times do |i|
      friend = FactoryGirl.create(:user)
      Friend.create(c_user: user.in_cassandra, id: Cequel.uuid(friend.id))
      print "#{user.username} is friends with #{friend.username} \n"
    end

    print "Success! #{user.username} should have #{amount} additional friends now.\n"
  end
end
