import saliweb.build
import saliweb.backend

class Config(saliweb.backend.Config):
    def populate(self, config):
        saliweb.backend.Config.populate(self, config)
        # Read our service-specific configuration
        self.script_directory = config.get('multifoxs', 'script_directory')

vars = Variables('config.py')
env = saliweb.build.Environment(vars, ['conf/live.conf'],
                                service_module='multifoxs', config_class=Config)
Help(vars.GenerateHelpText(env))

env.InstallAdminTools()
env.InstallCGIScripts()

Export('env')
SConscript('python/multifoxs/SConscript')
SConscript('lib/SConscript')
SConscript('txt/SConscript')
SConscript('test/SConscript')
SConscript('scripts/SConscript')
