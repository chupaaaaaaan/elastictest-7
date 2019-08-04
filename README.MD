# 設定ファイル考慮点

## elasticsearch.yml
- X-Pack Securityを有効にするために、 `xpack.security.enabled: true` が必要
- `network.host` を設定する場合は `discovery.seed_hosts` が必要
  - (localhost以外にelasticsearchをbindする場合) 自動的にproduction modeになるため
  - production modeではクラスタ設定必須
  - 以下のようなエラーメッセージが出る
```
[1] bootstrap checks failed
[1]: the default discovery settings are unsuitable for production use; at least one of [discovery.seed_hosts, discovery.seed_providers, cluster.initial_master_nodes] must be configured
```
- trial license以外でX-Pack Securityを有効にする場合は、transport (ノード間通信) のSSL設定必須
  - 以下のようなエラーメッセージが出る
```
[1] bootstrap checks failed
[1]: Transport SSL must be enabled if security is enabled on a [basic] license. Please set [xpack.security.transport.ssl.enabled] to [true] or disable security by setting [xpack.security.enabled] to [false]
```
- ビルトインユーザのパスワードを設定するために、クラスタのヘルスチェックをpassする必要がある
  - クラスタの初回起動時は、マスター適格ノードを明示的に設定 ( `cluster.initial_master_node` )
  - 以下のようなエラーメッセージが出る
```
Failed to determine the health of the cluster running at http://192.168.80.3:9200
Unexpected response code [503] from calling GET http://192.168.80.3:9200/_cluster/health?pretty
Cause: master_not_discovered_exception
```

## kibana.yml

## logstash.yml

## *.conf (logstash)



# 最初にやること

## elasticsearch

### サブスクリプション確認
```
# curl -XPOST http://localhost:9200/_license/start_trial?acknowledge=true

curl http://localhost:9200/_xpack/license
```

### SSL/TLS設定 
```
/usr/share/elasticsearch/bin/elasticsearch-certutil ca --out /etc/elasticsearch/certs/elastic-stack-ca.p12
#=> パスワードも設定

/usr/share/elasticsearch/bin/elasticsearch-certutil cert --ca /etc/elasticsearch/certs/elastic-stack-ca.p12 --out /etc/elasticsearch/certs/elastic-certificates.p12
#=> パスワードも設定

/usr/share/elasticsearch/bin/elasticsearch-keystore add xpack.security.transport.ssl.keystore.secure_password

/usr/share/elasticsearch/bin/elasticsearch-keystore add xpack.security.transport.ssl.truststore.secure_password
```

### ビルトインユーザのパスワード設定
```
/usr/share/elasticsearch/bin/elasticsearch-setup-passwords auto --batch

curl -u elastic:<ELASTIC_PASSWORD> http://localhost:9200/_cat/nodes?v
```

## kibana

### kibana keystore設定
```
/usr/share/kibana/bin/kibana-keystore create
#=> /usr/share/kibana/data/kibana.keystore が作成される

/usr/share/kibana/bin/kibana-keystore add elasticsearch.username
#=> kibanaと入力
#=> elasticsearch.usernameがkeystoreに登録される

/usr/share/kibana/bin/kibana-keystore add elasticsearch.password
#=> kibanaのパスワードを入力
#=> elasticsearch.passwordがkeystoreに登録される
```

### 必要なユーザ・ロールの作成
- logstash データ投入用ロール
```
logstash_writer:
    cluster:
        privilege:
            - manage_index_templates
            - monitor
            - manage_ilm
        index:
            - name: nyc-taxi-yellow-*
              privilege:
                  - write
                  - delete
                  - create_index
                  - manage
                  - manage_ilm
```
    
- logstash データ投入用ユーザ
```
logstash_internal:
    password: logstash_internal
    fullname: logstash_internal
    email: logstash_internal@mydomain.com
    role:
        - logstash_writer
```

- kibana データ閲覧用ロール
- kibana データ閲覧用ユーザ


## logstash

### logstash keystore設定
事前に作成したlogstashデータ投入用ユーザを設定する
キー名は*.confでoutputプラグイン (elasticsearch) にて指定したもの
```
/usr/share/logstash/bin/logstash-keystore --path.settings /etc/logstash create

/usr/share/logstash/bin/logstash-keystore --path.settings /etc/logstash add LS_INT_USR

/usr/share/logstash/bin/logstash-keystore --path.settings /etc/logstash add LS_INT_PWD
```


### ダッシュボードのエクスポート (from Default Space)
```
curl -u elastic:<ES_PASSWORD> http://localhost:5601/api/kibana/dashboards/export?dashboard=<DASHBOARD_ID> > export.json
```

### ダッシュボードのインポート (to any Space)
```
curl -H "Content-Type: application/json" -H "kbn-xsrf: true" -u elastic:<ES_PASSWORD> http://localhost:5601/s/<SPACE_ID>/api/kibana/dashboards/import --data-binary @export.json
```

## 参考url
https://www.elastic.co/guide/en/elastic-stack-overview/current/get-started-kibana-user.html
https://www.elastic.co/guide/en/elastic-stack-overview/current/built-in-users.html
https://www.elastic.co/guide/en/elastic-stack-overview/current/security-privileges.html

https://www.elastic.co/guide/en/elasticsearch/reference/current/network.host.html
https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-network.html
https://www.elastic.co/guide/en/elasticsearch/reference/current/bootstrap-checks.html
https://www.elastic.co/guide/en/elasticsearch/reference/current/discovery-settings.html
https://www.elastic.co/guide/en/elasticsearch/reference/current/important-settings.html
https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-discovery-settings.html
https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-discovery-bootstrap-cluster.html
https://www.elastic.co/guide/en/elasticsearch/reference/current/configuring-security.html
https://www.elastic.co/guide/en/elasticsearch/reference/current/configuring-tls.html

https://www.elastic.co/guide/en/kibana/current/xpack-spaces.html
https://www.elastic.co/guide/en/kibana/current/kibana-role-management.html
https://www.elastic.co/guide/en/kibana/current/development-security-rbac.html

https://www.elastic.co/guide/en/logstash/current/keystore.html
https://www.elastic.co/guide/en/logstash/current/ls-security.html
https://www.elastic.co/guide/en/logstash/current/keystore.html

https://www.elastic.co/jp/blog/getting-started-with-security
https://www.elastic.co/jp/blog/introducing-kibana-spaces-for-organization-and-security
https://www.elastic.co/jp/blog/how-to-migrate-to-kibana-spaces

http://acro-engineer.hatenablog.com/entry/2018/04/12/120000
https://tsgkdt.hatenablog.jp/entry/2019/05/23/235715



