module Whydicab
  class UpAndRunning < Thor
    desc 'prepare', 'prepares your sqlite test database, IT ERASES development db!'
    def prepare
      puts "removing all dbs, please ignore warnings"
      `rm sample_development.db`
      `rm sample_test.db`
      puts "recreating your development db"
      `echo 'DataMapper.auto_migrate!' | bin/merb -i`
      puts "for your convenience I am creating user admin with pwd admin"
      `echo 'User.create :login => "admin", :password => "admin", :password_confirmation => "admin"' | bin/merb -i`
      puts "sqlite3 requires a record on articles table for test.db to be used. creating it"
      `echo 'Article.create :title => "sqlite compliant", :body => "sqlite compliant", :user => User.first, :locale => "en"' | bin/merb -i`
      puts "copying development db to test database"
      `cp sample_development.db sample_test.rb`
      puts "so... run a spec to see if dbs creation succeeded"
    end
  end
end
