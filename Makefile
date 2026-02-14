build:
	python setup.py build_ext --inplace -j 8

build2:
	python2 setup.py build_ext --inplace -j 8

docs:
	make -C docs html

install:
	pip install .

uninstall:
	pip uninstall lifelib_pyql

tests-preload:
	LD_PRELOAD=/opt/QuantLib-1.1/lib/libQuantLib.so nosetests -v lifelib_pyql/test

tests: build
	python -m unittest discover -v

tests2: build2
	python2 -m unittest discover -v

build_ex:
	g++ -m32 -I/opt/local/include/ -I/opt/local/include/boost quantlib_test2.cpp \
    -o test2 -L/opt/local/lib/ -lQuantLib

clean:
	find lifelib_pyql -name \*.so -exec rm {} +
	find lifelib_pyql -name \*.pyc -exec rm {} +
	find lifelib_pyql -name \*.cpp -exec rm {} +
	find lifelib_pyql -name \*.c -exec rm {} +
	find lifelib_pyql -name \*.h -exec rm {} +
	-rm lifelib_pyql/termstructures/yields/{piecewise_yield_curve,discount_curve,forward_curve,zero_curve}.{pxd,pyx}
	rm -rf build
	rm -rf dist

.PHONY: build build2 docs clean
