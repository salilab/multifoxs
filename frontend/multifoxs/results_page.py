from flask import request, abort
import saliweb.frontend
import collections

InputData = collections.namedtuple('InputData',
        ['pdb', 'flexres', 'profile', 'email', 'num_conformations'])


def read_input_data(job):
    with open(job.get_path('filenames')) as fh:
        num_conformations = len(fh.readlines())
    with open(job.get_path('data.txt')) as fh:
        data = fh.readline().rstrip('\r\n').split()
        pdb, flexres, profile, email = data[:4]
        return InputData(pdb=pdb, flexres=flexres, profile=profile,
                         email=email, num_conformations=num_conformations)


def show_results_page(job):
    input_data = read_input_data(job)
    return saliweb.frontend.render_results_template("results_ok.html",
            job=job, input_data=input_data, max_state_number=5)
