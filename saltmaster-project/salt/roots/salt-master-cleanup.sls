{% set salt_projects_root = "/devops/projects" %}

{{ salt_projects_root }}:
    file.directory:
          - makedirs: True
# get the list of remote branches
{% for project, args in pillar.get('salt_git_projects', []).items() %}

{{ salt_projects_root }}/{{ project }}:
  file.directory:
    - makedirs: True

# get the list of remote branches
{% set pdict = 'salt_git_projects:' + project %}

{% set project_url = args['url'] %}
{% set project_target = salt['pillar.get'](pdict, {}).get('target', project) %}
{% set branches = [] %}
{% for origin_branch in salt['git.ls_remote'](remote=project_url, opts='--heads', user='root', identity='salt://common/keys/jenkins_id_rsa2', saltenv='saltmaster') %}
  {% set i = branches.append(origin_branch.replace('refs/heads/', '')) %}
{% endfor %}

# delete any directories that are no longer remote branches
{% for dir in salt['file.find'](salt_projects_root + '/' + project_target, type='d', maxdepth=0, print='name') %}
{% if dir not in branches %}
remove-{{ project_target }}-{{ dir }}:
  file.absent:
    - name: {{ salt_projects_root }}/{{ project_target }}/{{ dir }}
    - require_in:
      - file: /etc/salt/master.d/roots.conf
{% endif %}
{% endfor %}
{% endfor %}

# manage the file_roots config to generate environments
/etc/salt/master.d/roots.conf:
  file.managed:
    - template: jinja
    - source: salt://files/roots.conf
    - user: root
    - mode: 644
    - context:
        salt_projects_root: {{ salt_projects_root }} 

restart-saltmaster:
  service.restart:
    - name: salt-master
    - watch:
      - file: /etc/salt/master.d/roots.conf

