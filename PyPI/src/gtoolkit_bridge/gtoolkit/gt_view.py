# minimal, independent definition of @gtView annotation

def gtView(func):
	setattr(func, "gtView", True)
	return func
