#
# File: helpers.py
#

# this file can contain auxilliary functions used by project0.py and tests


def approx(a,b, tol=1e-10):
	return abs(a-b) < tol

def test_f(fun):
	'''
	Tests fun to ensure it returns a+b
	Args:
		fun (function): function for adding a+b
	'''

	if approx(fun(1.1,2.2), 3.3):
		print('Test 1 passed.')
	else:
		print('Test 1 failed.')

	if approx(fun(10.0,2.2), 12.2):
		print('Test 2 passed.')
	else:
		print('Test 2 failed.')

	return
	



