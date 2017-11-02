{% set salt_projects_root = "/devops/projects" %}

{{ salt_projects_root }}:
    file.directory:
          - makedirs: True

{% set project = pillar.get('project', '') %}
{% set branch = pillar.get('branch', '') %}

{% if project and branch %}

# get the list of remote branches
{% set pdict = 'salt_git_projects:' + project %}

# get the project URL
{% set project_url = salt['pillar.get'](pdict, {}).get('url', '') %}
{% set project_target = salt['pillar.get'](pdict, {}).get('target', project) %}

{%- if project_url %}

{%- if salt['file.directory_exists'](salt_projects_root + '/' + project_target + '/' + branch) %}
# Temporary fix since git.latest does not do the git reset
git-reset:
  cmd.run:
    - name: git reset --hard
    - cwd: {{ salt_projects_root }}/{{ project_target }}/{{ branch }}
{% endif %}

salt-repo-{{ project }}-{{ branch }}:
  git.latest:
    - name: {{ project_url }}
    - target: {{ salt_projects_root }}/{{ project_target }}/{{ branch }}
    - rev: {{ branch }}
    - branch: {{ branch }}
    - user: root
    - force_checkout: True
    - force_clone: True
    - force_fetch: True
    - force_reset: True
    - identity: /tools/deployment
    - require:
      - file: {{ salt_projects_root }}
{%- if salt['file.directory_exists'](salt_projects_root + '/' + project_target + '/' + branch) %}
      - cmd: git-reset
{% endif %}
    - require_in:
      - file: /etc/salt/master.d/roots.conf

create-tmpl:
  file.copy:
    - name: {{ salt_projects_root }}/{{ project_target }}/{{ branch }}/salt/roots/top.sls.tmpl
    - source: {{ salt_projects_root }}/{{ project_target }}/{{ branch }}/salt/roots/top.sls
    - force: True
    - require:
      - git: salt-repo-{{ project }}-{{ branch }}

update-top-file:
  file.managed:
    - name: {{ salt_projects_root }}/{{ project_target }}/{{ branch }}/salt/roots/top.sls
    - source: {{ salt_projects_root }}/{{ project_target }}/{{ branch }}/salt/roots/top.sls.tmpl
    - template: jinja
    - require:
      - git: salt-repo-{{ project }}-{{ branch }}

# manage the file_roots config to generate environments
/etc/salt/master.d/roots.conf:
  file.managed:
    - template: jinja
    - source: salt://files/roots.conf
    - user: root
    - mode: 644
    - context:
        salt_projects_root: {{ salt_projects_root }} 
    - require:
      - git: salt-repo-{{ project }}-{{ branch }}

{% endif %}
{% endif %}

restart-saltmaster:
  service.restart:
    - name: salt-master
    - watch:
      - file: /etc/salt/master.d/roots.conf

