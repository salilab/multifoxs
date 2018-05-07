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
            fh.write('1 2 3 4 5 6\n')
        cls = j._run_in_job_directory(j.run)
        self.assert_(isinstance(cls, saliweb.backend.SGERunner),
                     "SGERunner not returned")

    def test_bad_number_of_fields(self):
        """Test bad number of fields in input.txt"""
        j = self.make_test_job(multifoxs.Job, 'RUNNING')
        j.config.script_directory = 'foo'
        with open(os.path.join(j.directory, 'input.txt'), 'w') as fh:
            fh.write('1 2 3\n')
        self.assertRaises(saliweb.backend.SanityError,
                          j._run_in_job_directory, j.run)

    def test_invalid_character(self):
        """Test invalid character in input.txt"""
        j = self.make_test_job(multifoxs.Job, 'RUNNING')
        j.config.script_directory = 'foo'
        with open(os.path.join(j.directory, 'input.txt'), 'w') as fh:
            fh.write('1 2 3 4 5&;6\n')
        self.assertRaises(saliweb.backend.SanityError,
                          j._run_in_job_directory, j.run)

if __name__ == '__main__':
    unittest.main()
