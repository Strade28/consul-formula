{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot+"/map.jinja" import consul with context -%}

{#
#consul-init-env:
#  file.managed:
#    - name: {{ consul.init_env_path }}
#    - name: /etc/default/consul
#    {%- else %}
#    - name: /etc/sysconfig/consul
#    - makedirs: True
#    {%- endif %}
#    - user: root
#    - group: {{ consul.root_group }}
#    - mode: 0644
#    - contents:
#      - CONSUL_USER={{ consul.user }}
#      - CONSUL_GROUP={{ consul.group }}
#}
consul-init-file:
  file.managed:
    {%- if salt['test.provider']('service').startswith('systemd') %}
    - source: salt://{{ tplroot }}/files/consul.service
    - name: /etc/systemd/system/consul.service
    - mode: '0644'
    {%- elif salt['test.provider']('service') == 'upstart' %}
    - source: salt://{{ tplroot }}/files/consul.upstart
    - name: /etc/init/consul.conf
    - mode: '0644'
    {%- elif salt['test.provider']('service') == 'freebsdservice' %}
    - source: salt://{{ tplroot }}/files/consul.service.fbsd
    - name: /usr/local/etc/rc.d/consul
    - template: jinja
    - mode: '0555'
    {%- else %}
    - source: salt://{{ tplroot }}/files/consul.sysvinit
    - name: /etc/init.d/consul
    - mode: '0755'
    {%- endif %}
    - template: jinja
    - context:
      consul: {{ consul }}

{%- if consul.service %}

consul-service:
  service.running:
    - name: consul
    - enable: True
    - watch:
      - file: consul-init-file

{%- endif %}
