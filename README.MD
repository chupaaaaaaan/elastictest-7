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
- logstash データ投入用ユーザ
- logstash データ投入用ユーザ用パスワード

- kibana データ閲覧用ロール
- kibana データ閲覧用ユーザ
- kibana データ閲覧用ユーザ用パスワード


### logstash keystore設定
```
/usr/share/logstash/bin/logstash-keystore --path.settings /etc/logstash create
```
```
/usr/share/logstash/bin/logstash-keystore add LS_WRITER_PWD
```
