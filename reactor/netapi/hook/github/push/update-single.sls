#!py
import hashlib
import hmac
import logging

log = logging.getLogger(__name__)

def run():
    '''
    Verify the signature for a Github webhook and deploy the appropriate code
    '''
    _, signature = data['headers'].get('X-Hub-Signature').split('=')
    body = data['body']
    target = tag.split('/')[-1]
    key = __opts__.get('github', {}).get('webhook-key')
    if key:
      computed_signature = hmac.new(key, body,hashlib.sha1).hexdigest()
      if computed_signature == signature:
          project = data['post']['repository']['name'].lower()
          log.error('post {0}'.format(data['post']))
          if 'ref' in data['post']:
              branch = data['post']['ref'].split('/')[2]
              log.error('branch {0}'.format(branch))
          else:
              log.error('Returning nothing')
              return {}
          kwargs = {'saltenv': 'saltmaster', 'pillar': {'project': project, 'branch': branch, 'salt_branch': branch}}
          return {
              'github_webhook_update': {
                  'local.state.sls': [ {'tgt': 'saltconf-demo'}, {'arg': ['salt-master-git-single']}, {'kwarg': kwargs}, ]
              }
          }
      else:
        log.error('Signatures do not match')
        log.error('s: {} cs: {}'.format(signature, computed_signature))
    else:
        log.error('Returning nothing')
        return {}
