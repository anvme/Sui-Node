# Sui-Node Installation script

### Update node script will be available soon


How to install?
```
curl -sL https://raw.githubusercontent.com/anvme/Sui-Node/main/sui-node.sh | bash
```

### Check node metrics

1.Make metrics public. Run the command and restart your node

```
sed -i.bak "s/127.0.0.1/0.0.0.0/" /var/sui/fullnode.yaml
```
```
sudo systemctl restart sui
```

2. Go to https://node.sui.zvalid.com 
