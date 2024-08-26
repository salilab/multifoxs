import unittest
import saliweb.test
import tempfile
import os
import gzip
import re

# Import the multifoxs frontend with mocks
multifoxs = saliweb.test.import_mocked_frontend("multifoxs", __file__,
                                                '../../frontend')


def make_test_pdb(pdbf, compressed=False):
    def write(fh):
        fh.write(
            "REMARK\n"
            "ATOM      2  CA  ALA C   1      26.711  14.576   5.091\n")

    if compressed:
        with gzip.open(pdbf, 'wt') as fh:
            write(fh)
    else:
        with open(pdbf, 'w') as fh:
            write(fh)


def make_test_mmcif(fname, compressed=False):
    def write(fh):
        fh.write("""
loop_
_atom_site.group_PDB
_atom_site.type_symbol
_atom_site.label_atom_id
_atom_site.label_alt_id
_atom_site.label_comp_id
_atom_site.label_asym_id
_atom_site.auth_asym_id
_atom_site.label_seq_id
_atom_site.auth_seq_id
_atom_site.pdbx_PDB_ins_code
_atom_site.Cartn_x
_atom_site.Cartn_y
_atom_site.Cartn_z
_atom_site.occupancy
_atom_site.B_iso_or_equiv
_atom_site.label_entity_id
_atom_site.id
_atom_site.pdbx_PDB_model_num
ATOM N N . ALA A C 1 1 ? 27.932 14.488 4.257 1.000 23.91 1 1 1
ATOM N N . ALA B D 1 1 ? 27.932 14.488 4.257 1.000 23.91 1 2 1
""")

    if compressed:
        with gzip.open(fname, 'wt') as fh:
            write(fh)
    else:
        with open(fname, 'w') as fh:
            write(fh)


def make_test_profile(saxsf):
    with open(saxsf, 'w') as fh:
        fh.write("# sample profile\n"
                 "garbage\n"
                 "more garbage, ignored\n"
                 "0.1 -0.5\n"
                 "0.00000    9656627.00000000 2027.89172363\n")


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
            self.assertIn(
                b'PDB file test.pdb contains no ATOM or HETATM records',
                rv.data)

    def test_submit_page_bad_profile(self):
        """Test submit page with invalid profile"""
        with tempfile.TemporaryDirectory() as tmpdir:
            incoming = os.path.join(tmpdir, 'incoming')
            os.mkdir(incoming)
            multifoxs.app.config['DIRECTORIES_INCOMING'] = incoming
            c = multifoxs.app.test_client()
            pdbfile = os.path.join(tmpdir, 'test.pdb')
            make_test_pdb(pdbfile)
            saxsf = os.path.join(tmpdir, 'test.profile')
            with open(saxsf, 'w') as fh:
                fh.write("garbage\n")

            rv = c.post(
                '/job', data={'pdbfile': open(pdbfile, 'rb'),
                              'saxsfile': open(saxsf, 'rb'),
                              'modelsnumber': "5", "units": "unknown"})
            self.assertEqual(rv.status_code, 400)
            self.assertIn(b'Invalid profile uploaded', rv.data)

    def test_submit_page_pdb(self):
        """Test submit page, PDB format"""
        with tempfile.TemporaryDirectory() as tmpdir:
            incoming = os.path.join(tmpdir, 'incoming')
            os.mkdir(incoming)
            multifoxs.app.config['DIRECTORIES_INCOMING'] = incoming
            c = multifoxs.app.test_client()

            pdbf = os.path.join(tmpdir, 'test.pdb')
            make_test_pdb(pdbf)
            saxsf = os.path.join(tmpdir, 'test.profile')
            make_test_profile(saxsf)
            emptyf = os.path.join(tmpdir, 'emptyf')
            with open(emptyf, 'w') as fh:
                pass
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

            # Missing PDB file
            data = {'modelsnumber': '100', 'units': 'unknown',
                    'saxsfile': open(saxsf, 'rb'),
                    'hingefile': open(linkf, 'rb'), 'jobname': 'foobar'}
            rv = c.post('/job', data=data)
            self.assertEqual(rv.status_code, 400)
            self.assertIn(b'please specify PDB code or upload PDB/mmCIF file',
                          rv.data)

            # Missing SAXS file
            data = {'modelsnumber': '100', 'units': 'unknown',
                    'pdbfile': open(pdbf, 'rb'),
                    'hingefile': open(linkf, 'rb'), 'jobname': 'foobar'}
            rv = c.post('/job', data=data)
            self.assertEqual(rv.status_code, 400)
            self.assertIn(b'Please upload valid SAXS profile', rv.data)

            # Empty SAXS file
            data = {'modelsnumber': '100', 'units': 'unknown',
                    'pdbfile': open(pdbf, 'rb'),
                    'saxsfile': open(emptyf, 'rb'),
                    'hingefile': open(linkf, 'rb'), 'jobname': 'foobar'}
            rv = c.post('/job', data=data)
            self.assertEqual(rv.status_code, 400)
            self.assertIn(b'You have uploaded an empty SAXS profile', rv.data)

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

    def test_submit_page_mmcif(self):
        """Test submit page, mmCIF format"""
        with tempfile.TemporaryDirectory() as tmpdir:
            incoming = os.path.join(tmpdir, 'incoming')
            os.mkdir(incoming)
            multifoxs.app.config['DIRECTORIES_INCOMING'] = incoming
            c = multifoxs.app.test_client()

            pdbf = os.path.join(tmpdir, 'test.cif')
            make_test_mmcif(pdbf)
            saxsf = os.path.join(tmpdir, 'test.profile')
            make_test_profile(saxsf)
            linkf = os.path.join(tmpdir, 'test.linkers')
            with open(linkf, 'w') as fh:
                fh.write("189 A\n")

            data = {'modelsnumber': '100', 'units': 'unknown',
                    'pdbfile': open(pdbf, 'rb'), 'saxsfile': open(saxsf, 'rb'),
                    'hingefile': open(linkf, 'rb'), 'jobname': 'foobar'}
            rv = c.post('/job', data=data)
            self.assertEqual(rv.status_code, 200)
            r = re.compile(b'Your job <b>foobar</b> has been submitted.*'
                           b'Results will be found at',
                           re.MULTILINE | re.DOTALL)
            self.assertRegex(rv.data, r)

    def test_submit_pdb_code_pdb(self):
        """Test submit with a PDB code (PDB format)"""
        with tempfile.TemporaryDirectory() as tmpdir:
            incoming = os.path.join(tmpdir, 'incoming')
            os.mkdir(incoming)
            pdb_root = os.path.join(tmpdir, 'pdb')
            os.mkdir(pdb_root)
            multifoxs.app.config['DIRECTORIES_INCOMING'] = incoming
            multifoxs.app.config['PDB_ROOT'] = pdb_root
            c = multifoxs.app.test_client()

            os.mkdir(os.path.join(pdb_root, 'xy'))
            pdbf = os.path.join(pdb_root, 'xy', 'pdb1xyz.ent.gz')
            make_test_pdb(pdbf, compressed=True)
            saxsf = os.path.join(tmpdir, 'test.profile')
            make_test_profile(saxsf)
            linkf = os.path.join(tmpdir, 'test.linkers')
            with open(linkf, 'w') as fh:
                fh.write("189 A\n")

            data = {'modelsnumber': '100', 'units': 'unknown',
                    'pdbcode': '1xyz:C', 'saxsfile': open(saxsf, 'rb'),
                    'hingefile': open(linkf, 'rb'), 'jobname': 'foobar'}
            rv = c.post('/job', data=data)
            self.assertEqual(rv.status_code, 200)
            r = re.compile(b'Your job <b>foobar</b> has been submitted.*'
                           b'Results will be found at',
                           re.MULTILINE | re.DOTALL)
            self.assertRegex(rv.data, r)

    def test_submit_pdb_code_mmcif(self):
        """Test submit with a PDB code (mmCIF format)"""
        with tempfile.TemporaryDirectory() as tmpdir:
            incoming = os.path.join(tmpdir, 'incoming')
            os.mkdir(incoming)
            pdb_root = os.path.join(tmpdir, 'pdb')
            os.mkdir(pdb_root)
            multifoxs.app.config['DIRECTORIES_INCOMING'] = incoming
            multifoxs.app.config['PDB_ROOT'] = pdb_root
            multifoxs.app.config['MMCIF_ROOT'] = pdb_root
            c = multifoxs.app.test_client()

            os.mkdir(os.path.join(pdb_root, 'xy'))
            pdbf = os.path.join(pdb_root, 'xy', '1xyz.cif.gz')
            make_test_mmcif(pdbf, compressed=True)
            saxsf = os.path.join(tmpdir, 'test.profile')
            make_test_profile(saxsf)
            linkf = os.path.join(tmpdir, 'test.linkers')
            with open(linkf, 'w') as fh:
                fh.write("189 A\n")

            data = {'modelsnumber': '100', 'units': 'unknown',
                    'pdbcode': '1xyz:C', 'saxsfile': open(saxsf, 'rb'),
                    'hingefile': open(linkf, 'rb'), 'jobname': 'foobar'}
            rv = c.post('/job', data=data)
            self.assertEqual(rv.status_code, 200)
            r = re.compile(b'Your job <b>foobar</b> has been submitted.*'
                           b'Results will be found at',
                           re.MULTILINE | re.DOTALL)
            self.assertRegex(rv.data, r)


if __name__ == '__main__':
    unittest.main()
