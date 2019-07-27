# 最初にやること

## elasticsearch

### x-packトライアル有効化

curl -XPOST http://localhost:9200/_license/start_trial?acknowledge=true

### ビルトインユーザのパスワード設定
/usr/share/elasticsearch/bin/elasticsearch-setup-passwords auto --batch

Changed password for user apm_system
PASSWORD apm_system = V5ZTYg390F865PhvEPs5

Changed password for user kibana
PASSWORD kibana = CopQ5CmpE5nK5A7DEszh

Changed password for user logstash_system
PASSWORD logstash_system = u82LTiZJgcbx763JjnXj

Changed password for user beats_system
PASSWORD beats_system = 6nwQ2uRiUGN3wY7pcUTy

Changed password for user remote_monitoring_user
PASSWORD remote_monitoring_user = jDNMbtKoy1aViLNroxBl

Changed password for user elastic
PASSWORD elastic = 0oD6cWeWNl1KmterrgJ6
