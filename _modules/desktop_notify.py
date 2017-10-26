# -*- coding: utf-8 -*-
'''
Desktop Notification
'''

# Import Python libs
from __future__ import absolute_import
import logging
import os
import pwd

from salt.exceptions import CommandExecutionError

log = logging.getLogger(__name__)

# Define the module's virtual name
__virtualname__ = 'desktop_notify'


def __virtual__():
    return __virtualname__


def send(user, summary, message, icon=None):
    '''
    Send a message via notify-send to user

    CLI Example:

    .. code-block:: bash

        salt '*' desktop_notify.send user summary "message"

    '''
    ret = {'comment': 'unless execution succeeded', 'result': True}
    try:
        uid = pwd.getpwnam(user).pw_uid
    except KeyError:
        log.error('User does not exist')
        ret = {'comment': 'User does not exist', 'result': False}
        return ret

    environ = {}
    xdg_runtime_dir = '/run/user/{0}'.format(uid)
    is_dir = os.path.isdir(xdg_runtime_dir)

    if is_dir:
        environ['XDG_RUNTIME_DIR'] = xdg_runtime_dir

        cmd = 'notify-send'
        if icon:
            cmd = '{0} -i {1}'.format(cmd, icon)
        cmd = '{0} "{1}" "{2}"'.format(cmd, summary, message)
        result = __salt__['cmd.run_all'](cmd,
                                         runas=user,
                                         env=environ,
                                         python_shell=False)
        ret = {'comment': 'Notification sent', 'result': True}
        return ret
    else:
        raise CommandExecutionError('XDG_RUNTIME_DIR for {0} does not exist.'.format(user))
