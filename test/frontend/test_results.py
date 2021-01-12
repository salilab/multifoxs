import unittest
import saliweb.test
import re
import os

# Import the multifoxs frontend with mocks
multifoxs = saliweb.test.import_mocked_frontend("multifoxs", __file__,
                                                '../../frontend')


class Tests(saliweb.test.TestCase):
    """Check results page"""

    def test_results_file(self):
        """Test download of results files"""
        with saliweb.test.make_frontend_job('testjob') as j:
            # Good file
            j.make_file('good.log')
            c = multifoxs.app.test_client()
            rv = c.get('/job/testjob/good.log?passwd=%s' % j.passwd)
            self.assertEqual(rv.status_code, 200)

    def test_ok_job(self):
        """Test display of OK job"""
        with saliweb.test.make_frontend_job('testjob2') as j:
            j.make_file(
                "data.txt",
                "testpdb testflexres testprofile test4")
            j.make_file("filenames", "file1\nfile2\nfile3\n")
            c = multifoxs.app.test_client()
            rv = c.get('/job/testjob2?passwd=%s' % j.passwd)
            r = re.compile(
                    rb'/canvastext\.js.*'
                    rb'job\/testjob2\/testpdb\?passwd=.*'
                    rb'job\/testjob2\/hinges\.dat\?passwd=.*'
                    rb'job\/testjob2\/iq\.dat\?passwd=.*'
                    rb'job\/testjob2\/conformations\.zip\?passwd=.*'
                    rb'Your browser does not support the HTML 5 canvas.*'
                    rb'gnuplot\.show_plot\(\"jsoutput_3_plot_2\"\).*'
                    rb'foxs\/jsmol2\/js\/JSmol\.js.*',
                    re.MULTILINE | re.DOTALL)
            self.assertRegex(rv.data, r)

            j.make_file(
                "ensembles_size_1.txt",
                """1 |  2.39 | x1 2.39 (0.99, 2.97)
    0   | 1.000 (1.000, 1.000) | nodes27_m44.pdb.dat (0.004)
2 |  2.60 | x1 2.60 (0.99, 3.26)
    1   | 1.000 (1.000, 1.000) | nodes49_m15.pdb.dat (0.004)
3 |  2.69 | x1 2.69 (0.99, 4.00)
    2   | 1.000 (1.000, 1.000) | nodes23_m27.pdb.dat (0.004)
4 |  3.10 | x1 3.10 (1.02, 4.00)
    4   | 1.000 (1.000, 1.000) | nodes94_m27.pdb.dat (0.004)
5 |  3.26 | x1 3.26 (0.99, 4.00)
    7   | 1.000 (1.000, 1.000) | nodes50_m4.pdb.dat (0.004)
""")
            j.make_file("rg1", "20.6664 1\n19.8629 1\n20.5571 1\n19.8411 1\n")
            os.mkdir(os.path.join(j.directory, "e1"))
            j.make_file("e1/e1_0.pdb")
            c = multifoxs.app.test_client()
            rv = c.get('/job/testjob2?passwd=%s' % j.passwd)
            r = re.compile(
                    rb'Best scoring 1-state model.*'
                    rb'gnuplot\.show_plot\(\"jsoutput_3_plot_2\"\);.*'
                    rb'testjob2\/multi_state_model_1_1_1\.dat\?passwd=.*'
                    rb'testjob2\/e1\/e1_0\.pdb\?passwd=.*'
                    rb'backbone OFF; wireframe OFF; spacefill OFF;',
                    re.MULTILINE | re.DOTALL)
            self.assertRegex(rv.data, r)

    def test_failed_job(self):
        """Test display of failed job"""
        with saliweb.test.make_frontend_job('testjob3') as j:
            j.make_file(
                "data.txt",
                "testpdb testflexres testprofile test4")
            c = multifoxs.app.test_client()
            rv = c.get('/job/testjob3?passwd=%s' % j.passwd)
            r = re.compile(
                    rb'job\/testjob3\/testpdb\?passwd=.*'
                    rb'job\/testjob3\/hinges\.dat\?passwd=.*'
                    rb'job\/testjob3\/iq\.dat\?passwd=.*'
                    rb'Unfortunately, MultiFoXS failed to generate any.*'
                    rb'job\/testjob3\/multifoxs\.log\?passwd=.*',
                    re.MULTILINE | re.DOTALL)
            self.assertRegex(rv.data, r)


if __name__ == '__main__':
    unittest.main()
