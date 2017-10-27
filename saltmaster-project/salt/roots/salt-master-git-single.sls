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
    - require:
      - file: {{ salt_projects_root }}
{%- if salt['file.directory_exists'](salt_projects_root + '/' + project_target + '/' + branch) %}
      - cmd: git-reset
{% endif %}
    - require_in:
      - file: /etc/salt/master.d/roots.conf

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
