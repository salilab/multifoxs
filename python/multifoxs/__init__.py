import saliweb.backend
import os
import re

class LogError(Exception): pass

class MissingOutputsError(Exception): pass

class Job(saliweb.backend.Job):
    runnercls = saliweb.backend.SGERunner

    def _get_input_line(self):
        with open('input.txt') as par:
            input_line = par.readline().rstrip('\r\n')
        if len(input_line.split(' ')) != 5:
            raise saliweb.backend.SanityError(
                                  "Wrong number of fields in input.txt")
        if not re.match('[a-zA-Z0-9 \.-]+$', input_line):
            raise saliweb.backend.SanityError("Invalid character in input.txt")
        return input_line

    def run(self):
        input_line = self._get_input_line()
        script = """
date
hostname
module load imp gnuplot
ulimit -c 0
perl %s/runMultiFoXS.pl %s >& multifoxs.log
""" % (self.config.script_directory, input_line)

        r = self.runnercls(script)
        r.set_sge_options('-l arch=linux-x64,h_rt=300:00:00,mem_free=4G -p 0')
        #r.set_sge_options('-l arch=linux-x64,mem_free=4G -p 0')
        return r

    def postprocess(self):
        if not self.check_log_file():
            self.check_missing_outputs()

    def check_log_file(self):
        """Check log file for common errors. Return True if the log file
           indicates a problem with user input (as opposed to a failure at
           our end)."""
        with open('multifoxs.log') as fh:
            for line in fh:
                if 'ERROR' in line: # user error, not ours
                    return True
                if 'command not found' in line:
                    raise LogError("Job reported an error in multifoxs.log: %s"
                                   % line)

    def check_missing_outputs(self):
        """Check for missing output files"""
        expected = ['chis.png', 'hist.png']
        missing = [x for x in expected if not os.path.exists(x)]
        if missing:
            raise MissingOutputsError("Expected output files were not "
                                      "generated: %s" % " ".join(missing))

class Config(saliweb.backend.Config):
    def populate(self, config):
        saliweb.backend.Config.populate(self, config)
        # Read our service-specific configuration
        self.script_directory = config.get('multifoxs', 'script_directory')


def get_web_service(config_file):
    db = saliweb.backend.Database(Job)
    config = Config(config_file)
    return saliweb.backend.WebService(config, db)
