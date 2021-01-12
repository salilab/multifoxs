import saliweb.frontend
import os
import collections

InputData = collections.namedtuple(
    'InputData', ['pdb', 'flexres', 'profile', 'email'])

PDB = collections.namedtuple('PDB', ['filename', 'rg', 'weight', 'num'])


def read_num_conformations(job):
    with open(job.get_path('filenames')) as fh:
        return len(fh.readlines())


def read_input_data(job):
    with open(job.get_path('data.txt')) as fh:
        data = fh.readline().rstrip('\r\n').split()
        pdb, flexres, profile, email = data[:4]
        return InputData(pdb=pdb, flexres=flexres, profile=profile,
                         email=email)


class MultiStateModel(object):
    def __init__(self, job, state_num, model_num, ensemble_filename, color):
        self.state_num, self.color = state_num, color
        self.model_num = model_num
        with open(ensemble_filename) as fh:
            self.score, self.c1, self.c2 = self._read_ensemble_file(
                                                    fh, model_num)
        self.fit_file = "multi_state_model_%d_1_1.dat" % state_num
        self.pdbs = list(self._get_pdbs(job))

    def _get_pdbs(self, job):
        with open(job.get_path('rg%d' % self.state_num)) as fh:
            for i in range(self.state_num):
                filename = "e%d/e%d_%d.pdb" % (self.state_num,
                                               self.model_num, i)
                rg, weight = fh.readline().split()
                yield PDB(filename=filename, rg=float(rg),
                          weight=float(weight), num=i)

    def _read_ensemble_file(self, fh, model_num):
        for line in fh:
            if ' x1 ' in line:
                tmp = line.split('|')
                if len(tmp) > 1 and tmp[0].strip().isdigit():
                    if int(tmp[0]) == model_num:
                        score = float(tmp[1])
                        c1c2 = tmp[2].split('(')[1].split(')')[0].split(',')
                        c1 = float(c1c2[0])
                        c2 = float(c1c2[1])
                        return score, c1, c2
        raise ValueError("Could not find ensemble")


def get_multi_state_models(job, max_state):
    colors = ["x1a9850",  # green
              "xe26261",  # red
              "x3288bd",  # blue
              "x00FFFF",
              "xA6CEE3"]
    for size in range(1, max_state + 1):
        fn = job.get_path("ensembles_size_%d.txt" % size)
        if os.path.exists(fn):
            yield MultiStateModel(job, size, 1, fn, colors[size-1])


def show_results_page(job):
    input_data = read_input_data(job)
    try:
        num_conformations = read_num_conformations(job)
    except FileNotFoundError:
        return saliweb.frontend.render_results_template(
            "results_failed.html",
            job=job, input_data=input_data)

    max_state = 5
    return saliweb.frontend.render_results_template(
        "results_ok.html",
        job=job, input_data=input_data, max_state_number=max_state,
        multi_state_models=list(get_multi_state_models(job, max_state)),
        num_conformations=num_conformations)
