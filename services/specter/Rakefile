require 'yaml'
require 'active_record'

task :migrate do

  database = YAML.load(File.read('database.yml'))
  ActiveRecord::Base.establish_connection(database)

  migration_files = Dir['db/migrate/*.rb']

  migrations = migration_files.map do |migration_file|
    require "./#{migration_file}"

    timestamp, underscored_class_name = File.basename(migration_file).gsub(/\.rb$/,'').split('_',2)

    # TODO: I could probably search for constants added instead
    #   of this approach to relying on the filename and the class name
    #   being exactly the same as one another

    underscored_class_name.camelize.constantize
  end

  migrator = ActiveRecord::Migrator.new(:up,migrations)
  migrator.run
end
