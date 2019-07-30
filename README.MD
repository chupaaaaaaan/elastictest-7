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
