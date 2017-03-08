import unittest
import multifoxs
import saliweb.test
import os

class Tests(saliweb.test.TestCase):

    def test_postprocess_ok(self):
        """Test postprocess with OK log file"""
        j = self.make_test_job(multifoxs.Job, 'RUNNING')
        d = saliweb.test.RunInDir(j.directory)
        with open('multifoxs.log', 'w') as fh:
            fh.write("everything ok\n")
        j.postprocess()

    def test_postprocess_bad_log(self):
        """Test postprocess with bad log file"""
        j = self.make_test_job(multifoxs.Job, 'RUNNING')
        d = saliweb.test.RunInDir(j.directory)
        with open('multifoxs.log', 'w') as fh:
            fh.write("ERROR: Invalid input profile\n")
        self.assertRaises(multifoxs.LogError, j.postprocess)

if __name__ == '__main__':
    unittest.main()
