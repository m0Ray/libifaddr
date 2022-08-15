import setuptools
import sys
import os
import subprocess

from Cython.Build import cythonize

setuptools.setup(
    name="libifaddr",
    version="1.0.0",
    author="Dmitry Kirilin",
    author_email="m0ray@protonmail.ch",
    description = "Get network interface addresses with easy and simple interface",
    url="https://github.com/m0Ray/libifaddr",
    data_files = None,
    ext_modules = cythonize(
        setuptools.extension.Extension("libifaddr",        ["libifaddr.pyx",]),
    ),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: Linux",
    ],
    setup_requires=[
        "cython",
    ],
    install_requires=[
    ],
)