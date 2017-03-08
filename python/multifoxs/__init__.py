import saliweb.backend

class Job(saliweb.backend.Job):
    runnercls = saliweb.backend.SGERunner

    def run(self):
        # TODO
        par = open('input.txt', 'r')
        input_line = par.readline().strip()

        script = """
module load imp gnuplot
ulimit -c 0
perl /netapp/sali/dina/MultiFoXSServer/runMultiFoXS.pl %s >& multifoxs.log
""" % (input_line)

        r = self.runnercls(script)
        r.set_sge_options('-l arch=linux-x64,h_rt=300:00:00,mem_free=4G -p 0')
        #r.set_sge_options('-l arch=linux-x64,mem_free=4G -p 0')
        return r

class Config(saliweb.backend.Config):
    def populate(self, config):
        saliweb.backend.Config.populate(self, config)
        # Read our service-specific configuration
        self.script_directory = config.get('multifoxs', 'script_directory')


def get_web_service(config_file):
    db = saliweb.backend.Database(Job)
    config = Config(config_file)
    return saliweb.backend.WebService(config, db)
