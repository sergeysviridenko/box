# Configure all of the configured databases
class Database
  attr_accessor :application_root, :config, :settings

  def initialize(application_root, config, settings)
    @application_root = application_root
    @config = config
    @settings = settings
  end

  def configure
    return unless settings.key?('databases')

    settings['databases'].each do |db|
      mysql(db)
      postgres(db)

      if settings.key?('mongodb') && settings['mongodb']
        mongo(db)
      end
    end
  end

  private

  def mysql(db)
    config.vm.provision 'shell' do |s|
      s.name = "Creating MySQL Database: #{db}"
      s.path = "#{application_root}/provision/mysql.sh"

      vagrant_cnf = File.open("#{application_root}/templates/.my.vagrant.cnf", 'rb')
      root_cnf = File.open("#{application_root}/templates/.my.root.cnf", 'rb')

      s.args = [db, vagrant_cnf.read, root_cnf.read]
    end
  end

  def postgres(db)
    config.vm.provision 'shell' do |s|
      s.name = "Creating Postgres Database: #{db}"
      s.path = "#{application_root}/provision/postgres.sh"
      s.args = [db]
    end
  end

  def mongo(db)
    config.vm.provision 'shell' do |s|
      s.name = "Creating Mongo Database: #{db}"
      s.path = "#{application_root}/provision/mongo.sh"
      s.args = [db]
    end
  end
end
