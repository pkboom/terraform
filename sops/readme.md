# Create KMS key

1. Go to [Customer managed keys](https://us-east-2.console.aws.amazon.com/kms/home?region=us-east-2#/kms/keys)

2. Click on 'Create key'

<img src="images/bucket1.png" />
<img src="images/bucket2.png" />

# Run `sops` before run terraform

```bash
sops --encrypt secret.json > secret.enc.json
```

# To use `vi` as a default editor, if not.

Set `export EDITOR="/Applications/TextEdit.app/Contents/MacOS/TextEdit"` in `.zshrc`
