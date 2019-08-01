# 設定ファイル考慮点

## elasticsearch.yml

## kibana.yml

## logstash.yml

## *.conf (logstash)



# 最初にやること

## elasticsearch

### x-packトライアル有効化
```
curl -XPOST http://localhost:9200/_license/start_trial?acknowledge=true
```
```
curl http://localhost:9200/_xpack/license
```

### ビルトインユーザのパスワード設定
```
/usr/share/elasticsearch/bin/elasticsearch-setup-passwords auto --batch
```

### パスワード確認
```
curl -u elastic:<ELASTIC_PASSWORD> http://localhost:9200/_cat/nodes?v
```


### kibana keystore設定
```
/usr/share/kibana/bin/kibana-keystore create
#=> /usr/share/kibana/data/kibana.keystore が作成される
```
```
/usr/share/kibana/bin/kibana-keystore add elasticsearch.username
#=> kibanaと入力
#=> elasticsearch.usernameがkeystoreに登録される
```
```
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


### logstash keystore設定
事前に作成したlogstashデータ投入用ユーザを設定する
キー名は*.confでoutputプラグイン (elasticsearch) にて指定したもの
```
/usr/share/logstash/bin/logstash-keystore --path.settings /etc/logstash create
```
```
/usr/share/logstash/bin/logstash-keystore --path.settings /etc/logstash add LS_INT_USR
```
```
/usr/share/logstash/bin/logstash-keystore --path.settings /etc/logstash add LS_INT_PWD
```


### ダッシュボードのエクスポート (from Default Space)
```
curl -u elastic:<ES_PASSWORD> http://localhost:5601/api/kibana/dashboards/export?dashboard=<DASHBOARD_ID> > export.json
```

### ダッシュボードのインポート (to Awesome Space)
```
curl -H "Content-Type: application/json" -H "kbn-xsrf: true" -u elastic:<ES_PASSWORD> http://localhost:5601/s/<SPACE_ID>/api/kibana/dashboards/import --data-binary @export.json
```
