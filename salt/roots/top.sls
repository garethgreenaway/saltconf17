saltconf17-{{ pillar['salt_branch'] }}:
  'G:roles:saltconf17 and I@salt_branch:{{ pillar["salt_branch"] }}':
    - match: compound
    - basics
    - saltconf17

