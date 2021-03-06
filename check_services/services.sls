{% for host, hostinfo in salt['pillar.get']('machines', {}).iteritems() %}
 {% if hostinfo.has_key('services') %}

  {% if grains['os_family'] == 'RedHat' %}
   {% set preset_servicenames = { 
    'apache': "httpd", 
    'cron': "crond",
    'dhcp': "dhcpd",
    'dns': "named",
    'ftp': "proftpd",
    'mail': "postfix",
    'mysql': "mysqld",
    'nfs': "nfs",
    'sge': "sgemaster." + grains['host'], 
    'ssh': "sshd" } %}
  {% elif grains['os_family'] == 'Debian' %}
   {% set preset_servicenames = { 
    'apache': "apache2", 
    'cron': "cron", 
    'dhcp': "isc-dhcp-server", 
    'dns': "bind9",
    'ftp': "proftpd",
    'mail': "postfix",
    'mysql': "mysql",
    'nfs': "nfs-kernel-server",
    'sge': "sgemaster." + grains['host'],
    'ssh': "ssh" } %}
##    'sge': "gridengine-master" } %}
  {% endif %}

  {% if hostinfo.has_key('SaltHostname') %}
   {% if grains['id'] == hostinfo['SaltHostname'] %}
    {% for service in hostinfo['services'] %}
     {% if preset_servicenames.has_key(service) %}
      {% if service == "sge" %}
{{ preset_servicenames[service] }}__{{ grains['id'] }}:
  cmd.run:
    - name: pgrep sge_qmaster

      {% else %}
{{ preset_servicenames[service] }}__{{ grains['id'] }}:
  module.run:
    - name: customservice.status
    - m_name: {{ preset_servicenames[service] }}
#{{ preset_servicenames[service] }}__{{ grains['id'] }}__static_state: 
#  service.running:
#    - name: {{ preset_servicenames[service] }}
#    - enable: True

      {% endif %}
     {% else %}

{{ service }}__{{ grains['id'] }}:
  module.run:
    - name: customservice.status
    - m_name: {{ service }} 
#{{ service }}__{{ grains['id'] }}__static_state: 
#  service.running: 
#    - name: {{ service }}
#    - enable: True

     {% endif %}

    {% endfor %}
   {% endif %}
  {% endif %}

 {% endif %}
{% endfor %}
