#
# File: helpers.py
#

# this file defines the optimization problems and test

from tqdm import tqdm
import numpy as np

class OptimizationProblem:

    @property
    def xdim(self):
        # dimension of x
        return self._xdim

    @property
    def prob(self):
        # problem name
        return self._prob
    
    @property
    def n(self):
        # number of allowed evaluations
        return self._n
    
    def _reset(self):
        self._ctr = 0

    def count(self):
        return self._ctr

    def nolimit(self):
        # sets n to inf, useful for plotting/debugging
        self._n = np.inf
        
    def x0(self):
        '''
        Returns:
            x0 (np.array): (xdim,) randomly initialized x
        '''
        return np.random.randn(self.xdim)

    def f(self, x):
        '''Evaluate f
        Args:
            x (np.array): input
        Returns:
            f (float): evaluation
        '''
        assert x.ndim == 1

        self._ctr += 1

        return self._wrapped_f(x)
    
    def _wrapped_f(self, x):
        raise NotImplementedError

    def g(self, x):
        '''Evaluate jacobian of f
        Args:
            x (np.array): input
        Returns:
            jac (np.array): jacobian of f wrt x
        '''
        assert x.ndim == 1

        self._ctr += 2

        return self._wrapped_g(x)

class ConstrainedOptimizationProblem(OptimizationProblem):

    @property
    def cdim(self):
        # number of constraints
        return self._cdim

    @property
    def nc(self):
        # number of allowed constraint evals
        return self._nc

    def _reset(self):
        self._ctr = 0

    def count(self):
        return self._ctr

    def nolimit(self):
        # sets n to inf, useful for plotting/debugging
        self._n = np.inf

    def c(self, x):
        '''Evaluate constraints
        Args:
            x (np.array): input
        Returns:
            c (np.array): (cdim,) evaluation of constraints
        '''
        assert x.ndim == 1
        
        self._ctr += 1

        return self._wrapped_c(x)

    def _wrapped_c(self, x):
        raise NotImplementedError


class Simple1(ConstrainedOptimizationProblem):
    
    def __init__(self):
        self._xdim = 2
        self._cdim = 2
        self._prob = 'simple1'
        self._n = 2000
        self._reset()

    def x0(self):
        return np.random.rand(self._xdim) * 2.0

    def _wrapped_f(self, x):
        return -x[0] * x[1]  + 2.0 / (3.0 * np.sqrt(3.0))

    def _wrapped_g(self, x):
        return np.array([
            -x[1],
            -x[0],
                ])

    def _wrapped_c(self,x):
        return np.array([
            x[0] + x[1]**2 - 1,
            -x[0] - x[1]
            ])



class Simple2(ConstrainedOptimizationProblem):

    def __init__(self):
        self._xdim = 2
        self._cdim = 2
        self._prob = 'simple2'
        self._n = 2000
        self._reset()

    def x0(self):
        return np.random.rand(self._xdim) * 2.0 - 1.0

    def _wrapped_f(self, x):
        return 100 * (x[1] - x[0]**2)**2 + (1-x[0])**2

    def _wrapped_g(self, x):
        return np.array([
            2*(-1 + x[0] + 200*x[0]**3 - 200*x[0]*x[1]),
            200*(-x[0]**2 + x[1])
                ])

    def _wrapped_c(self,x):
        return np.array([
            (x[0]-1)**3 - x[1] + 1,
            x[0] + x[1] - 2,
            ])


class Simple3(ConstrainedOptimizationProblem):

    def __init__(self):
        self._xdim = 3
        self._cdim = 1
        self._prob = 'simple3'
        self._n = 2000
        self._reset()

    def x0(self):
        b = 2.0 * np.array([1.0, -1.0, 0.0])
        a = -2.0 * np.array([1.0, -1.0, 0.0])
        return np.random.rand(3) * (b-a) + a

    def _wrapped_f(self, x):
        return x[0] - 2*x[1] + x[2] + np.sqrt(6.0)

    def _wrapped_g(self, x):
        return np.array([1., -2., 1.])

    def _wrapped_c(self, x):
        return np.array([x[0]**2 + x[1]**2 + x[2]**2 - 1.])



def test_optimize(optimize):
    '''
    Tests optimize to ensure it passes
    Args:
        optimize (function): function optimizing a given problem
    '''

    for test in [Simple1, Simple2, Simple3]:

        p = test()
        print('Testing on %s...' % p.prob)

        solution_feasible = []
        any_count_exceeded = False
        for seed in tqdm(range(500)):
            p = test()
            np.random.seed(seed)
            x0 = p.x0()
            xb = optimize(p.f, p.g, p.c, x0, p.n, p.count, p.prob)
            if p.count() > p.n:
                any_count_exceeded = True
                break
            p._reset()
            solution_feasible.append(np.all(p.c(xb) <= 0.0))

        if any_count_exceeded:
            print('Failed %s. Count exceeded.'%p.prob)
            continue

        # to pass, optimize must return a feasible point >=95% of the time.

        numfeas = np.sum(solution_feasible)
        if numfeas >= 0.95*500:
            print('Pass: optimize returns a feasible solution on %d/%d random seeds.' % (numfeas,500))
        else:
            print('Fail: optimize returns a feasible solution on %d/%d random seeds.' % (numfeas,500))

    return
    

