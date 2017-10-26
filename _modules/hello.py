# -*- coding: utf-8 -*-
'''
A simple module to give a greeting
'''

from __future__ import absolute_import

__virtualname__ = 'hello'


def __virtual__():
    return __virtualname__


def world():
    '''
    Say Hello
    '''
    return "Hello World!"
