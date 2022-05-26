import unittest
import saliweb.test
import tempfile
import os
import re

# Import the multifoxs frontend with mocks
multifoxs = saliweb.test.import_mocked_frontend("multifoxs", __file__,
                                                '../../frontend')


class Tests(saliweb.test.TestCase):
    """Check submit page"""

    def test_submit_page_pdb_no_atoms(self):
        """Test submit page with PDB containing no ATOM records"""
        with tempfile.TemporaryDirectory() as tmpdir:
            incoming = os.path.join(tmpdir, 'incoming')
            os.mkdir(incoming)
            multifoxs.app.config['DIRECTORIES_INCOMING'] = incoming
            c = multifoxs.app.test_client()
            pdbfile = os.path.join(tmpdir, 'test.pdb')
            with open(pdbfile, 'w') as fh:
                fh.write("garbage\n")

            rv = c.post(
                '/job', data={'pdbfile': open(pdbfile, 'rb'),
                              'modelsnumber': "5", "units": "unknown"})
            self.assertEqual(rv.status_code, 400)
            self.assertIn(b'PDB file contains no ATOM or HETATM records',
                          rv.data)

    def test_submit_page_bad_profile(self):
        """Test submit page with invalid profile"""
        with tempfile.TemporaryDirectory() as tmpdir:
            incoming = os.path.join(tmpdir, 'incoming')
            os.mkdir(incoming)
            multifoxs.app.config['DIRECTORIES_INCOMING'] = incoming
            c = multifoxs.app.test_client()
            pdbfile = os.path.join(tmpdir, 'test.pdb')
            with open(pdbfile, 'w') as fh:
                fh.write(
                    "ATOM      2  CA  ALA     1      26.711  14.576   5.091\n")
            saxsf = os.path.join(tmpdir, 'test.profile')
            with open(saxsf, 'w') as fh:
                fh.write("garbage\n")

            rv = c.post(
                '/job', data={'pdbfile': open(pdbfile, 'rb'),
                              'saxsfile': open(saxsf, 'rb'),
                              'modelsnumber': "5", "units": "unknown"})
            self.assertEqual(rv.status_code, 400)
            self.assertIn(b'Invalid profile uploaded', rv.data)

    def test_submit_page(self):
        """Test submit page"""
        with tempfile.TemporaryDirectory() as tmpdir:
            incoming = os.path.join(tmpdir, 'incoming')
            os.mkdir(incoming)
            multifoxs.app.config['DIRECTORIES_INCOMING'] = incoming
            c = multifoxs.app.test_client()

            pdbf = os.path.join(tmpdir, 'test.pdb')
            with open(pdbf, 'w') as fh:
                fh.write(
                    "REMARK\n"
                    "ATOM      2  CA  ALA     1      26.711  14.576   5.091\n")
            saxsf = os.path.join(tmpdir, 'test.profile')
            with open(saxsf, 'w') as fh:
                fh.write("# sample profile\n"
                         "garbage\n"
                         "more garbage, ignored\n"
                         "0.1 -0.5\n"
                         "0.00000    9656627.00000000 2027.89172363\n")
            linkf = os.path.join(tmpdir, 'test.linkers')
            with open(linkf, 'w') as fh:
                fh.write("189 A\n")

            data = {}
            # Invalid models number
            rv = c.post('/job', data=data)
            self.assertEqual(rv.status_code, 400)
            self.assertIn(b'Invalid value for number of models', rv.data)
            data['modelsnumber'] = '100'

            # Invalid units
            rv = c.post('/job', data=data)
            self.assertEqual(rv.status_code, 400)
            self.assertIn(b'Invalid units', rv.data)
            data['units'] = 'unknown'

            # Successful submission (no email)
            data = {'modelsnumber': '100', 'units': 'unknown',
                    'pdbfile': open(pdbf, 'rb'), 'saxsfile': open(saxsf, 'rb'),
                    'hingefile': open(linkf, 'rb'), 'jobname': 'foobar'}
            rv = c.post('/job', data=data)
            self.assertEqual(rv.status_code, 200)
            r = re.compile(b'Your job <b>foobar</b> has been submitted.*'
                           b'Results will be found at',
                           re.MULTILINE | re.DOTALL)
            self.assertRegex(rv.data, r)

            # Make sure data.txt is generated
            with open(os.path.join(incoming, 'foobar', 'data.txt')) as fh:
                contents = fh.read()
            self.assertEqual(
                contents,
                "input.pdb test.linkers test.profile None 100\n")

            # Successful submission (with email)
            data = {'modelsnumber': '100', 'units': 'unknown',
                    'pdbfile': open(pdbf, 'rb'), 'saxsfile': open(saxsf, 'rb'),
                    'hingefile': open(linkf, 'rb'),
                    'email': 'test@example.com'}
            rv = c.post('/job', data=data)
            self.assertEqual(rv.status_code, 200)
            r = re.compile(b'Your job <b>job\\S+</b> has been submitted.*'
                           b'Results will be found at.*'
                           b'You will be notified at test@example.com when',
                           re.MULTILINE | re.DOTALL)
            self.assertRegex(rv.data, r)


if __name__ == '__main__':
    unittest.main()
