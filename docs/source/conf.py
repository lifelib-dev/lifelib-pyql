# -*- coding: utf-8 -*-
"""Sphinx configuration for lifelib-pyql reference documentation."""

import sys
import os

sys.path.insert(0, os.path.abspath('../..'))

project = 'lifelib-pyql'
copyright = '2024, Fumito Hamamura'
author = 'Fumito Hamamura'

version = '0.1'
release = '0.1'

extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.napoleon',
    'sphinx.ext.viewcode',
    'sphinx.ext.intersphinx',
]

napoleon_numpy_docstring = True
napoleon_google_docstring = False

intersphinx_mapping = {
    'python': ('https://docs.python.org/3', None),
    'numpy': ('https://numpy.org/doc/stable', None),
}

templates_path = ['_templates']
exclude_patterns = ['_build']

source_suffix = '.rst'
master_doc = 'index'

html_theme = 'alabaster'
html_theme_options = {
    'font_size': 11,
}
html_static_path = []
