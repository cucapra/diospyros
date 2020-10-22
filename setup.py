from setuptools import setup

setup(
    name='cdios',
    version='1.0.0',
    description='A minimal C frontend to Diospyros',
    author='Alexa VanHattum',
    author_email='avh@cs.cornell.edu',
    url='https://github.com/cucapra/diospyros',
    license='MIT',
    platforms='ALL',

    install_requires=['click'],

    py_modules=['cdios'],

    entry_points={
        'console_scripts': [
            'cdios = cdios:cdios',
        ],
    },

    classifiers=[
        'Environment :: Console',
        'Programming Language :: Python :: 3',
    ],
)