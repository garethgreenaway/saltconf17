# -*- coding: utf-8 -*-
'''
Schedule jobs
'''

from __future__ import absolute_import
import datetime

__virtualname__ = 'schedule_test'


def __virtual__():
    return __virtualname__ if 'schedule.add' in __salt__ else False


def sched(run='first', minutes=1):
    '''
    Add a job to the Salt schedule to run once
    at a specific time.

    CLI Example:

    .. code-block:: bash

        salt '*' deploy_schedule.sched run='first' minutes='60'

    '''
    n10 = datetime.datetime.now() + datetime.timedelta(minutes=minutes)
    timetorun = "{0}-{1}-{2}T{3}:{4}:{5}".format(
        n10.year, n10.month, n10.day, n10.hour,
        n10.minute, n10.second)
    timetorun = n10.strftime('%Y-%m-%dT%H:%M:%S')
    job_kwargs = ('run='+run)
    __salt__['schedule.add']('schedule_test',
                             function='event.send',
                             once=timetorun,
                             job_args=['schedule/test_event'],
                             job_kwargs=job_kwargs)
    return True
