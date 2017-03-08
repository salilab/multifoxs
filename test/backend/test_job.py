import unittest
import multifoxs
import saliweb.test
import saliweb.backend
import os

class JobTests(saliweb.test.TestCase):
    """Check custom Job class"""

    def test_run(self):
        """Test successful run method"""
        j = self.make_test_job(multifoxs.Job, 'RUNNING')
        j.config.script_directory = 'foo'
        with open(os.path.join(j.directory, 'input.txt'), 'w') as fh:
            fh.write('1 2 3\n')
        cls = j._run_in_job_directory(j.run)
        self.assert_(isinstance(cls, saliweb.backend.SGERunner),
                     "SGERunner not returned")

if __name__ == '__main__':
    unittest.main()
