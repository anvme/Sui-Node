# Sui-Node Installation script

### Installation and Update script for your sui node. Simple choice the action on start


How to install or update your node? Just run
```
wget https://raw.githubusercontent.com/anvme/Sui-Node/main/sui-node.sh && chmod +x sui-node.sh && ./sui-node.sh
```

### Check node metrics

1. Make metrics public. Run the command and restart your node

```
sed -i.bak "s/127.0.0.1/0.0.0.0/" /var/sui/fullnode.yaml
```
```
sudo systemctl restart sui
```

2. Go to https://node.sui.zvalid.com 
