import unittest
import multifoxs
import saliweb.test
import saliweb.backend
import os

basic_config = """
[general]
admin_email: test@salilab.org
service_name: test_service
socket: test.socket

[backend]
user: test
state_file: state_file
check_minutes: 10

[database]
db: testdb
frontend_config: frontend.conf
backend_config: backend.conf

[directories]
install: /
incoming: /in
preprocessing: /preproc

[oldjobs]
archive: 1h
expire: 1d

[multifoxs]
script_directory: sdir
"""


class Tests(saliweb.test.TestCase):
    """Check custom Config class"""

    def test_basic(self):
        """Test Config with basic config file"""
        with open('test.config', 'w') as fh:
            fh.write(basic_config)
        c = multifoxs.Config('test.config')
        self.assertEqual(c.script_directory, 'sdir')
        os.unlink('test.config')


if __name__ == '__main__':
    unittest.main()
