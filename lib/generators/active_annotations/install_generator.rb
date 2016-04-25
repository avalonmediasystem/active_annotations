module ActiveAnnotations
  class InstallGenerator < Rails::Generators::Base
     desc "This generator copies the ActiveAnnotations database migrations to /db/migrate"
     
     def copy_migrations
       rake "active_annotations:install:migrations"
       rake "db:migrate"
     end
  end
end
